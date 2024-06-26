# Packages
i3 polybar lutris pulseaudio tlp playerctl pamixer nitrogen dex xss-lock networkmanager picom dunst alacritty bluetuith firefox maim xclip  ttf-roboto-mono-nerd nerd-fonts-noto-sans-mono-extended  cobang thunar thunar-archive-plugin thunar-volman lxappearance fish ungoogled-chromium museeks-bin vlc cava ark

# add the alias to your shell's config
```
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
```
# Setup the base repo
```
cd ~
echo ".cfg" >> .gitignore
git clone --bare https://github.com/craftybloxy/dotfiles/ $HOME/.cfg
```

# apply the changes
```
config checkout
```
