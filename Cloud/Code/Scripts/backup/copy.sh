cp ~/README.MD ./script.sh
echo "1 - etc"
cp --parents '/etc/lightdm/lightdm.conf' .
cp --parents '/etc/X11/xorg.conf.d/40-libinput.conf' .
echo "2 - chromium"
cp --parents -R '/home/crafty/.config/chromium/Default/' .
echo "3 - music"
cp --parents -R '/home/crafty/Music/Flacs' .
cp --parents -R '/home/crafty/Music/Mp3s' .
cp --parents -R '/home/crafty/Music/Playlists'  .
echo "6 - documents"
cp --parents -R '/home/crafty/Documents' .
echo "7 - games"
cp --parents -R '/home/crafty/Games' .
sudo cp --parent '/etc/environment' .

#!/bin/sh
set -e

DEST="$HOME/backup"      # explicit target instead of "."
mkdir -p "$DEST"
cd "$DEST"

cp ~/README.MD ./README.MD

echo "1 - etc"
cp --parents /etc/lightdm/lightdm.conf .
cp --parents /etc/X11/xorg.conf.d/40-libinput.conf .
cp --parents /etc/environment .

echo "2 - chromium (excluding caches)"
rsync -a --relative \
    --exclude 'Cache' --exclude 'Code Cache' --exclude 'GPUCache' \
    --exclude 'Service Worker' --exclude 'Application Cache' \
    /home/crafty/.config/chromium/Default .

echo "3 - music"
cp --parents -R /home/crafty/Music/Flacs .
cp --parents -R /home/crafty/Music/Mp3s .
cp --parents -R /home/crafty/Music/Playlists .

echo "4 - documents"
cp --parents -R /home/crafty/Documents .

echo "5 - games"
cp --parents -R /home/crafty/Games .

echo "Done -> $DEST"