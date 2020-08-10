#!/bin/sh -x

$ANDROID_HOME/tools/bin/avdmanager create avd \
    -k "system-images;android-${API_LEVEL};${IMG_TYPE};${SYS_IMG}" \
    -n testing

exec $*