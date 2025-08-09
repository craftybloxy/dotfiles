# Install paru
cd ~
sudo pacman --noconfirm -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg --noconfirm  -si
cd ~
rm -rf ./paru

# Install packages using paru
paru --noconfirm -S  i3 bluez pipewire pipewire-pulse wireplumber playerctl maim xclip bluetuith picom dunst tlp pamixer dex xss-lock networkmanager nerd-fonts fish lxqt-policykit-agent obsidian 
paru --noconfirm -S mpv helix ark lutris firefox cava cobang lxappearance strawberry cavalier ungoogled-chromium readest vscodium dconf-editor vesktop
paru --noconfirm -S openvpn deluge nicotine+
paru --noconfirm -S nautilus gvfs gvfs-afc gvfs-mtp file-roller unrar zip
paru --noconfirm -S gnome-text-editor gnome-console loupe gpaste

# add the alias to your shell's config
# clone the bare config repo
# configure gut to ignore untracked files
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
cd ~
echo ".cfg" >> .gitignore
git clone --bare https://github.com/craftybloxy/dotfiles/ $HOME/.cfg
config config --local status.showUntrackedFiles no

# apply the changes
config checkout

#Setup de
sudo systemctl enable --now --user pipewire.service
sudo systemctl enable --now --user wireplumber.service
sudo systemctl enable --now lightdm.service
chsh -s /usr/bin/fish

echo "you should also set lightdm's greeter to 'greeter-session=lightdm-slick-greeter'
