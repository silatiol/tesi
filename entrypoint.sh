#!/bin/sh -x
#c49d05e25736098dab3e83a2e8eb618d286b3ecc

#echo n | avdmanager create avd \
#    -k "system-images;android-${API_LEVEL};${IMG_TYPE};${SYS_IMG}" \
#    -n testing 

  # Enable keyboard support in QEMU (for VNC)



echo y | rm /tmp/.X0-lock
echo y | rm -r /root/.android/avd
echo y | cp -r /root/avd /root/.android/avd
echo 'hw.keyboard = true' >> /root/.android/avd/testing.avd/config.ini
#echo y | cp -r /root/snap /root/.android/avd/testing.avd/snapshots/default_boot/
echo y | adb kill-server
echo y | rm -f /root/.android/adbkey /root/.android/adbkey.pub
echo y | cp /root/keys/adbkey /root/.android
ip=$(ip address show eth0 | grep inet | cut -d: -f2 | awk '{ print $2}' | cut -d '/' -f1 | awk '{ print $1}')
echo y | socat tcp-listen:5554,bind=$ip,fork tcp:127.0.0.1:5554 &
echo y | socat tcp-listen:5555,bind=$ip,fork tcp:127.0.0.1:5555 &
echo y | adb start-server

exec $*