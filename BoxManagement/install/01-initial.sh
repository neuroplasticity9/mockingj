#!/usr/bin/env bash
# Initial setup after insert GuestAdditions.iso in a fresh centos/7 image.

SCRIPT_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPT_DIR" ]]; then SCRIPT_DIR="$PWD"; fi
source "${SCRIPT_DIR}/../library.sh"


function initial_setup() {
  progress "Preparing VM..." && \
    sudo yum install -y epel-release && \
    sudo yum -y upgrade && \
    sudo yum install -y gcc kernel-devel kernel-headers dkms make bzip2 perl
}

function install_guest_additions() {
  progress "Install Guest Additions" && \
    sudo mount /dev/sr0 /mnt && \
    sudo sh /mnt/VBoxLinuxAdditions.run && \
    sudo umount /mnt
}

function install_misc_utilities() {
  sudo yum install -y expect yum-utils
}

function misc_configuration() {
  # Turn off SElinux
  target_string='^(SELINUX=)enforcing$'
  substitute='disabled'
  config_path="/etc/selinux/config"
  sudo sed -i -r "s|${target_string}|\1${substitute}|w ${SED_LOG}" ${config_path}
  if [[ -s ${SED_LOG} ]]
  then
    modified=$( cat ${SED_LOG} )
    progress "Changed config patterned [${target_string}] to [${modified}] in ${config_path}."
  else
    warning "Could not find config pattern [${target_string}] in ${config_path}. \n\tSkipping..."
  fi
}

script_started
initial_setup
install_guest_additions
install_misc_utilities
misc_configuration
script_ended
