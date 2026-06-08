if status is-interactive
    # Commands to run in interactive sessions can go here
end
alias p="paru"
alias pu="nice -n 19 ionice -c 3 paru -Syu --noconfirm"
alias po="paru -Rns $(pacman -Qdtq)"
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias vpn="sudo openvpn --config ~/AirVPN.ovpn"
alias fs="fresh"
set -g fish_greeting
bind \cs "source ./.venv/bin/activate.fish && echo "--venv--""
set EDITOR fs

# uv
fish_add_path "/home/crafty/.local/bin"

string match -q "$TERM_PROGRAM" vscode
and . (code --locate-shell-integration-path fish)
