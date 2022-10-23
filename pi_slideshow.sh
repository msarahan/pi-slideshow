#!/usr/bin/env bash
# set -ex

# auto mount usb
mkdir -p /media/usb
chown -R $USER:$GROUP /media/usb
if [ -z "$(grep /media/usb /etc/fstab)" ]; then
    echo "/dev/sda1 /media/usb auto auto,nofail,noatime,users,ro 0 0" >> /etc/fstab
fi

# turn off screen blanking

if [ -z "$(grep '\-dpms' /etc/lightdm/lightdm.conf)" ]; then
    echo "[SeatDefaults]" >> /etc/lightdm/lightdm.conf
    echo "xserver-command=X -s 0 -dpms" >> /etc/lightdm/lightdm.conf
fi

# remove point-rpi (automatic pointer positioning)
sed -i '/point-rpi/d' /etc/xdg/lxsession/LXDE-pi/autostart

# hide cursor
if [ -z $(which unclutter) ]; then
	apt-get install -y unclutter
fi
if [ -z "$(grep unclutter /etc/xdg/lxsession/LXDE-pi/autostart)" ]; then
	echo "unclutter &" >> /etc/xdg/lxsession/LXDE-pi/autostart
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
	apt-get install -y feh
fi
cat << EOF > /run_slideshow.sh
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

if [ -z "$(grep run_slideshow /etc/xdg/lxsession/LXDE-pi/autostart)" ]; then
	cat << EOF >> /etc/xdg/lxsession/LXDE-pi/autostart
bash /run_slideshow.sh &
	EOF
fi

raspi-config nonint enable_overlayfs

