local options = {

-- The token to authenticate with Musixmatch's API.
-- If you get rate limited, you can obtain a new token with
-- curl --location https://apic-desktop.musixmatch.com/ws/1.1/token.get?app_id=web-desktop-app-v1.0
    musixmatch_token = '2601309c5b74ae54ef0abff432a06b29fcff8500f4ae2403e10035',
    auto_download = true,  -- Enable/disable auto-download on file load
}
local utils = require 'mp.utils'

require 'mp.options'.read_options(options)

local function show_error(message)
    mp.msg.error(message)
    if mp.get_property_native('vo-configured') then
        mp.osd_message(message, 2)
    end
end

local function show_message(message)
    mp.msg.info(message)
    if mp.get_property_native('vo-configured') then
        mp.osd_message(message, 2)
    end
end

local function curl(args)
    local r = mp.command_native({name = 'subprocess', capture_stdout = true, args = args})

    if r.killed_by_us then
        return
    end

    if r.status < 0 then
        show_error('subprocess error: ' .. r.error_string)
        return
    end

    if r.status > 0 then
        show_error('curl failed with code ' .. r.status)
        return
    end

    local response, error = utils.parse_json(r.stdout)

    if error then
        show_error('Unable to parse the JSON response')
        return
    end

    return response
end

local function get_metadata()
    local metadata = mp.get_property_native('metadata')

    if metadata == nil then
        return false, 'Metadata not yet loaded'
    end

    local title = metadata.title or metadata.TITLE or metadata.Title
    local artist = metadata.artist or metadata.ARTIST or metadata.Artist

    if not title then
        return false, 'This song has no title metadata'
    end

    if not artist then
        return false, 'This song has no artist metadata'
    end

    return title, artist
end

local function save_lyrics(lyrics)
    if lyrics == '' then
        show_message('Lyrics not found')
        return
    end

    local current_sub_path = mp.get_property('current-tracks/sub/external-filename')

    if current_sub_path and lyrics:find('^%[') == nil then
        show_message("Only lyrics without timestamps available")
        return
    end

    local path = mp.get_property('path')
    local lrc_path = (path:match('(.*)%.[^/]*$') or path) .. '.lrc'

    if path:find('://') then
        if lyrics:find('^%[') then
            mp.commandv('sub-add', 'memory://' .. lyrics)
            show_message('LRC added')
        else
            show_message('Lyrics have no timestamps')
        end
        return
    end

    local success_message = 'LRC downloaded'
    if current_sub_path then
        local _, current_sub_filename = utils.split_path(current_sub_path)
        local current_sub = io.open(current_sub_path)
        local backup = io.open('/tmp/' .. current_sub_filename, 'w')
        if current_sub and backup then
            backup:write(current_sub:read('*a'))
            success_message = success_message .. '. The old one has been backupped to /tmp.'
        end
        if current_sub then
            current_sub:close()
        end
        if backup then
            backup:close()
        end
    end

    local lrc, error = io.open(lrc_path, 'w')
    if lrc == nil then
        show_error(error)
        return
    end
    lrc:write(lyrics)
    lrc:close()

    if lyrics:find('^%[') then
        mp.command(current_sub_path and 'sub-reload' or 'rescan-external-files')
        mp.osd_message(success_message)
    else
        mp.osd_message('Lyrics without timestamps downloaded')
    end
end

local function download_musixmatch_lyrics()
    local title, artist = get_metadata()

    if title == false then
        return
    end

    show_message('Downloading lyrics...')

    local response = curl({
        'curl',
        '--silent',
        '--get',
        '--cookie', 'x-mxm-token-guid=' .. options.musixmatch_token,
        'https://apic-desktop.musixmatch.com/ws/1.1/macro.subtitles.get',
        '--data', 'app_id=web-desktop-app-v1.0',
        '--data', 'usertoken=' .. options.musixmatch_token,
        '--data-urlencode', 'q_track=' .. title,
        '--data-urlencode', 'q_artist=' .. artist,
    })

    if not response then
        return
    end

    if response.message.header.status_code == 401 and response.message.header.hint == 'renew' then
        show_message('Musixmatch token rate limited')
        return
    end

    if response.message.header.status_code ~= 200 then
        show_message('Request failed: ' .. response.message.header.status_code)
        return
    end

    local body = response.message.body.macro_calls

    local lyrics = ''
    if body['matcher.track.get'].message.header.status_code == 200 then
        if body['matcher.track.get'].message.body.track.has_subtitles == 1 then
            lyrics = body['track.subtitles.get'].message.body.subtitle_list[1].subtitle.subtitle_body
        elseif body['matcher.track.get'].message.body.track.has_lyrics == 1 then
            lyrics = body['track.lyrics.get'].message.body.lyrics.lyrics_body
        elseif body['matcher.track.get'].message.body.track.instrumental == 1 then
            return
        end
    end

    save_lyrics(lyrics)
end

-- Manual download keybinding
mp.add_key_binding('Alt+m', 'musixmatch-download', download_musixmatch_lyrics)

-- Auto-download lyrics when file loads
mp.register_event('file-loaded', function()
    if not options.auto_download then
        return
    end

    local path = mp.get_property('path')
    if not path or path:find('://') then
        return
    end

    -- Check if lyrics already exist
    local lrc_path = (path:match('(.*)%.[^/]*$') or path) .. '.lrc'
    local lrc_file = io.open(lrc_path, 'r')
    if lrc_file then
        lrc_file:close()
        return
    end

    -- Wait for metadata to load
    mp.add_timeout(1.0, function()
        download_musixmatch_lyrics()
    end)
end)

mp.add_key_binding('Alt+o', 'offset-sub', function()
    local sub_path = mp.get_property('current-tracks/sub/external-filename')

    if not sub_path then
        show_error('No external subtitle is loaded')
        return
    end

    local r = mp.command_native({
        name = 'subprocess',
        capture_stdout = true,
        args = {'ffmpeg', '-loglevel', 'quiet', '-itsoffset', mp.get_property('sub-delay'), '-i', sub_path, '-f', sub_path:match('[^%.]+$'), '-fflags', '+bitexact', '-'}
    })

    if r.status < 0 then
        show_error('subprocess error: ' .. r.error_string)
        return
    end

    if r.status > 0 then
        show_error('ffmpeg failed with code ' .. r.status)
        return
    end

    local sub_file, error = io.open(sub_path, 'w')
    if sub_file == nil then
        show_error(error)
        return
    end
    sub_file:write((r.stdout:gsub('^\n', '')))
    sub_file:close()

    mp.set_property('sub-delay', 0)
    mp.command('sub-reload')
    mp.osd_message('Subtitles updated')
end)
