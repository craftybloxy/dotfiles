if status is-interactive
    # Commands to run in interactive sessions can go here
end
alias "p"="paru"
alias "po"="paru -Rns $(pacman -Qdtq)"
alias "co"="vscodium -g"
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias vpn="sudo openvpn --config ~/AirVPN.ovpn"
alias hx="helix"
set -g fish_greeting
bind \cs "source ./.venv/bin/activate.fish && echo "--venv--""
set EDITOR hx

#yazi stuff
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

# uv
fish_add_path "/home/crafty/.local/bin"
