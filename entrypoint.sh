#!/bin/sh -x

echo n | $ANDROID_HOME/tools/bin/avdmanager create avd \
    -k "system-images;android-${API_LEVEL};" \
    -n testing -b "${IMG_TYPE};${SYS_IMG}"
(
  # Enable keyboard support in QEMU (for VNC)
  echo 'hw.keyboard = true';
) >> /root/.android/avd/testing.avd/config.ini

exec $*