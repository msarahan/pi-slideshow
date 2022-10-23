#!/usr/bin/env bash
# set -ex

# auto mount usb
mkdir -p /media/usb
if [ -z "$(grep /media/usb /etc/fstab)" ]; then
    sudo echo "/dev/sda1 /media/usb auto auto,nofail,noatime,users,ro 0 0" | sudo tee -a /etc/fstab
fi

# turn off screen blanking

if [ -z "$(grep '\-dpms' /etc/lightdm/lightdm.conf)" ]; then
    sudo echo "[SeatDefaults]" | sudo tee -a /etc/lightdm/lightdm.conf
    sudo echo "xserver-command=X -s 0 -dpms" | sudo tee -a /etc/lightdm/lightdm.conf
fi

# remove point-rpi (automatic pointer positioning)
sudo sed -i '/point-rpi/d' /etc/xdg/lxsession/LXDE-pi/autostart
sudo sed -i '/xscreensaver/d' /etc/xdg/lxsession/LXDE-pi/autostart
sudo sed -i '/pcmanfm/d' /etc/xdg/lxsession/LXDE-pi/autostart

# hide cursor
if [ -z $(which unclutter) ]; then
	sudo apt-get install -y unclutter
fi
if [ -z "$(grep unclutter /etc/xdg/lxsession/LXDE-pi/autostart)" ]; then
	sudo echo "unclutter &" | sudo tee -a /etc/xdg/lxsession/LXDE-pi/autostart
fi

# turn off screen automatically at certain time
#write out current crontab
crontab -l > mycron
if [ -z "$(grep display_power mycron)" ]; then
	#echo new cron into cron file
	echo "0 9 * * * vcgencmd display_power 1" >> mycron
	echo "0 21 * * * vcgencmd display_power 0" >> mycron
	#install new cron file
	crontab mycron
fi
rm mycron

if [ -z $(which feh) ]; then
	sudo apt-get install -y feh
fi
cat << EOF > /home/$USER/run_slideshow.sh
feh \
    --recursive \
    --randomize \
    --fullscreen \
    --quiet \
    --hide-pointer \
    --auto-rotate \
    --slideshow-delay 30 \
    --reload 39600 \
    /media/usb
EOF

chmod +x ~/run_slideshow.sh

if [ -z "$(grep run_slideshow /etc/xdg/lxsession/LXDE-pi/autostart)" ]; then
	echo "/home/$USER/run_slideshow.sh &" | sudo tee -a /etc/xdg/lxsession/LXDE-pi/autostart
fi

# raspi-config nonint enable_overlayfs

