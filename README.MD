
# Packages
```shell
i3 polybar lutris pulseaudio tlp playerctl pamixer nitrogen dex xss-lock networkmanager picom dunst alacritty bluetuith firefox maim xclip nerd-fonts cobang thunar thunar-archive-plugin thunar-volman lxappearance fish ungoogled-chromium museeks-bin vlc cava ark
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

# credits
|info|link|
|------|------|
|Bare repo trick|https://www.atlassian.com/git/tutorials/dotfiles |
|Swapping worksapces betwween two screens |https://gist.github.com/fbrinker/df9cfbc84511d807f45041737ff3ea02?permalink_comment_id=4972587#gistcomment-4972587|

