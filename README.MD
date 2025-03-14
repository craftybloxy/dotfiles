# Packages
```shell
i3 polybar lutris pulseaudio tlp playerctl pamixer nitrogen dex xss-lock networkmanager picom dunst alacritty bluetuith firefox maim xclip nerd-fonts cobang thunar thunar-archive-plugin thunar-volman lxappearance fish ungoogled-chromium museeks-bin vlc cava ark sptlrx helix strawberry cavalier
```

# add the alias to your shell's config
```shell
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
```

# Setup the base repo
```shell
cd ~
echo ".cfg" >> .gitignore
git clone --bare https://github.com/craftybloxy/dotfiles/ $HOME/.cfg
```

# apply the changes
```shell
config checkout
```
