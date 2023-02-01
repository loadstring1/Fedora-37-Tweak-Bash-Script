#!/bin/bash
clear
echo "This script supports only fedora 37"
echo "You are free to view this script's source code"
echo "Script features:"
echo "- install multimedia codecs if they are not (could fix most youtube videos not loading)"
echo "- make your shutdowns and reboots faster (fedora linux process timeout reduced so it shutsdown and reboots faster)"
echo "- make dnf package manager faster"
echo "- install steam"
echo "- install nvidia drivers"
echo "Never download bash scripts from unofficial source. If you downloaded this script from non-official source its required that you delete this one and download it from official source."
echo "The creator of this script is not responsible for any damages made to your device. You are running this script on your own risk. If it works it works. If it doesnt it doesnt. Same thing applies even if you change script's source code. This means there is no warranty if something goes wrong. Do you agree? (y/n)"
read answer
if [[ "$answer" != "y" ]]; then
  echo "The script will exit now because you did not agree."
  exit
fi
if [ "$EUID" -ne 0 ]; then
  echo "You will be asked for your password because the script was not ran as root"
  echo "Attempting to re-run the script as root"
  if [[ -f "./f37tweaks.sh" ]] then
    sudo bash ./f37tweaks.sh
  else
    echo "The script got renamed during its runtime please do not rename the script during its runtime"
    echo "Its required that you change the name back to f37tweaks.sh"
  fi
  exit
fi
echo "Checking for modified config files"
config="./configfiles"
if [[ -d "$config" ]] && [[ -f "$config/system.conf" ]] && [[ -f "$config/user.conf" ]] && [[ -f "$config/dnf.conf" ]] && [[ -f "$config/originaldnf.conf" ]] then
  echo "modified config files are ready"
  echo "please do not rename config files"
  echo "please do not put the config files into different directory while the script is running"
  echo "please do not put the script into different directory while its running"
else
  echo "script cannot continue because modified config files are missing"
  echo "please make sure you downloaded this script from official source or make sure your download was not interrupted"
  echo "if none of those above work please make sure the script is inside its directory with config files"
  exit
fi
mayneedreboot=false
function checkmultimedia () {
  echo "Checking for multimedia codecs"
  echo "Installing rpmfusion free package from official source (mirrors.rpmfusion.org)"
  dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
  echo "Installing rpmfusion nonfree"
  dnf install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
  if dnf list --installed ffmpeg-libs; then
      echo "ffmpeg-libs multimedia codec is already installed"
  else
      echo "Multimedia codecs are not installed"
      echo "Installing multimedia codecs..."
      dnf install ffmpeg-libs
  fi
  mainmenu
}
function installsteam () {
  echo "Installing rpmfusion nonfree"
  dnf install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
  echo "Installing steam"
  if dnf list --installed steam; then
    echo "Steam already installed"
  else
    dnf install steam
  fi
  mainmenu
}
function installnvidia () {
  echo "Are you sure that your GPU (graphics card) is from nvidia? (y/n)"
  read answer
  if [[ $answer != "y" ]] then
    mainmenu
    return
  fi
  echo "Secure boot enabled? (y/n)"
  read answer
  sbenabled=$answer
  if [[ $sbenabled = "y" ]] then
    echo "Nvidia drivers signed in secure boot? (y/n)"
    read answer
    signed=$answer
  fi
  if [[ $sbenabled = "y" ]] && [[ $signed = "n" ]] then
    echo "removing nvidia drivers if they got already installed by user"
    dnf remove \*nvidia\* --exclude=nvidia-gpu-firmware
    cat /usr/share/doc/akmods/README.secureboot
    echo "PLEASE READ THE INSTUCTION BEFORE SIGNING NVIDIA DRIVERS"
    echo "PLEASE READ THE INSTUCTION BEFORE SIGNING NVIDIA DRIVERS"
    echo "PLEASE READ THE INSTUCTION BEFORE SIGNING NVIDIA DRIVERS"
    echo "To import the key, the command will ask for a password to protect the key. You will have to enter this password during the special EFI window"
    echo "To import the key, the command will ask for a password to protect the key. You will have to enter this password during the special EFI window"
    echo "To import the key, the command will ask for a password to protect the key. You will have to enter this password during the special EFI window"
    /usr/sbin/kmodgenca
    mokutil --import /etc/pki/akmods/certs/public_key.der
    echo "Your pc will automaticially reboot after pressing enter. Device will reboot to EFI window where you need to enroll keys in purpose of signing nvidia drivers."
    read
    sudo reboot
    exit
  elif [[ $sbenabled = "y" ]] && [[ $signed = "y" ]] then
      sudo dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda -y
      echo "The script will wait 5 minutes now just to make sure that the nvidia modules get built properly"
      echo "After 5 minutes your device will reboot to apply the changes "
      echo "PLEASE DO NOT CLOSE THIS TERMINAL AND WAIT 5 MINUTES SO NVIDIA DRIVERS CAN GET PROPERLY BUILT (AFTER 5 MINUTES YOUR DEVICE WILL REBOOT SO DONT DO ANYTHING FOR 5 MINUTES UNLESS YOU WANT YOUR UNSAVED WORK GET LOST)"
      sleep 5m
      sudo reboot
      exit
  elif [[ $sbenabled = "n" ]] then
      sudo dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda -y
  fi
  mainmenu
}
function tweakshutdown () {
  clear
  echo "Replacing systemd config files with modified systemd config files"
  rm -f /etc/systemd/system.conf
  rm -f /etc/systemd/user.conf
  cp $config/system.conf /etc/systemd
  cp $config/user.conf /etc/systemd
  mayneedreboot=true
  echo "successfully replaced systemd config files with modified systemd config files"
  mainmenu
}
function revertshutdown () {
  echo "systemd will now reinstall in purpose of reverting all the changes made to it"
  rm -f /etc/systemd/system.conf
  rm -f /etc/systemd/user.conf
  mayneedreboot=true
  dnf reinstall systemd -y
  changesmenu
}
function fasterdnf () {
  echo "Replacing dnf configuration with modified dnf configuration"
  rm -f /etc/dnf/dnf.conf
  cp $config/dnf.conf /etc/dnf
  echo "successfully replaced dnf config with modified dnf config"
  mainmenu
}
function revertdnf () {
  echo "current dnf configuration will be replaced with default dnf configuration"
  rm -f /etc/dnf/dnf.conf
  cp $config/originaldnf.conf /etc/dnf/dnf.conf
  echo "successfully replaced dnf config with default dnf config"
  changesmenu
}
function exitscript () {
   if [[ "$mayneedreboot" = "true" ]]; then
      echo "Your device needs to be rebooted to apply the changes"
      echo "Do you want to reboot now? (y/n)"
      read rebootanswer
      if [[ "$rebootanswer" = "y" ]]; then
        sudo reboot
        exit
      fi
      echo "You can still use your device. The changes will apply after you reboot or shutdown."
  fi
  exit
}
function mainmenu () {
  echo "Press return (enter) key to enter main menu"
  read
  clear
  main
  exit
}
function changesmenu () {
  echo "Press return (enter) key to enter revert changes menu"
  read
  clear
  revertchanges
  exit
}
function revertchanges () {
  mainFunc=(revertdnf revertshutdown main exitscript)
  echo "0: revert dnf speedup"
  echo "1: revert to default process timeout (default shutdown timer and reboot timer)"
  echo "2: back to main menu"
  echo "3: safely exit the script"
  read answer
  if ! [[ $answer =~ ^[0-9]+$ ]]; then
    mainmenu
    return
  fi
  clear
  "${mainFunc[$answer]}"
}
function main () {
  mainArray=(checkmultimedia tweakshutdown fasterdnf installsteam installnvidia revertchanges exitscript)
  echo "0: install multimedia codecs"
  echo "1: reduce shutdown timer and reboot timer (fedora 37 linux systemd will kill processes after 5s instead of 90s at reboot and shutdown)"
  echo "2: makes dnf package manager faster"
  echo "3: install steam"
  echo "4: install nvidia drivers (and sign them if secure boot is enabled)"
  echo "5: revert changes menu"
  echo "6: safely exit the script"
  read answer
  if ! [[ $answer =~ ^[0-9]+$ ]]; then
    mainmenu
    return
  fi
  clear
  "${mainArray[$answer]}"
}
main
