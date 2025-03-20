if status is-interactive
    # Commands to run in interactive sessions can go here
end
alias "p"="paru"
alias "po"="paru -Rsn $(pacman -Qdtq)"
alias "hx"="helix"
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
bind \cs "source ./venv/bin/activate.fish && echo "--venv--""
