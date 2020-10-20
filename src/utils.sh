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
  echo "Apps will be installed"
  for f in $(ls apps/*.apk); do
    adb install $f
  done

  echo "Done"
}

function start_x11 () {
  /usr/bin/x11vnc -id $(xwininfo -root -tree | grep 'Android Emulator' | tail -n1 | sed "s/^[ \t]*//" | cut -d ' ' -f1) -forever -shared -nopw &
}

sleep 5
start_x11
sleep 1
install_google_play