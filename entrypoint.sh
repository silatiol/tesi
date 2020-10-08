#!/bin/sh -x
#c49d05e25736098dab3e83a2e8eb618d286b3ecc

echo n | avdmanager create avd \
    -k "system-images;android-${API_LEVEL};${IMG_TYPE};${SYS_IMG}" \
    -n testing 
(
  # Enable keyboard support in QEMU (for VNC)
  echo 'hw.keyboard = true';
) >> /root/.android/avd/testing.avd/config.ini

exec $*