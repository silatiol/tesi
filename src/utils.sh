#!/bin/bash

function wait_emulator_to_be_ready () {
  boot_completed=false
  while [ "$boot_completed" == false ]; do
    status=$(adb wait-for-device shell getprop sys.boot_completed | tr -d '\r')
    echo "Boot Status: $status"

    if [ "$status" == "1" ]; then
      boot_completed=true
    else
      sleep 1
    fi      
  done
}

function change_language_if_needed() {
  if [ ! -z "${LANGUAGE// }" ] && [ ! -z "${COUNTRY// }" ]; then
    wait_emulator_to_be_ready
    echo "Language will be changed to ${LANGUAGE}-${COUNTRY}"
    adb root && adb shell "setprop persist.sys.language $LANGUAGE; setprop persist.sys.country $COUNTRY; stop; start" && adb unroot
    echo "Language is changed!"
  fi
}

function install_google_play () {
  wait_emulator_to_be_ready
  echo "Google Play Service will be installed"
  adb root
  adb remount
  adb push etc /system
  adb push framework /system
  adb push app /system
  adb push priv-app /system
  adb unroot
}

function prepare_zip () {
  umask 000
  unzip gapps.zip 'Core/*'
  rm Core/setup*
  lzip -d Core/*.lz
  for f in $(ls Core/*.tar); do
    tar -x --strip-components 2 -f $f
  done
}

change_language_if_needed
sleep 1
prepare_zip
sleep 1
install_google_play