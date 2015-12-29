#!/usr/bin/env bash
# Initial setup after insert GuestAdditions.iso in a fresh centos/7 image.

SCRIPT_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPT_DIR" ]]; then SCRIPT_DIR="$PWD"; fi
source "${SCRIPT_DIR}/../library.sh"


function initial_setup() {
  progress "Initial setup..." && \
    sudo yum install -y epel-release && \
    sudo yum -y upgrade && \
    sudo yum install -y gcc kernel-devel kernel-headers dkms make bzip2 perl
}

function install_guest_additions() {
  installed=$( lsmod | grep vboxguest )
  if [[ "${installed}" != "" ]]
  then
    warning "Guest Additions already installed. \n\tSkipping"
  else
    progress "Installing Guest Additions" && \
      sudo mount /dev/sr0 /mnt && \
      sudo sh /mnt/VBoxLinuxAdditions.run && \
      sudo umount /mnt
  fi
}

function install_misc_utilities() {
  sudo yum groupinstall -y "Development Tools" && \
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
    sudo setenforce 0
  else
    warning "Could not find config pattern [${target_string}] in ${config_path}. \n\tSkipping..."
  fi

  # Clean up old kernel versions and keep only 2 most recent kernels
  configured=$( grep 'installonly_limit=2' /etc/yum.conf )
  if [[ "${configured}" != "" ]]
  then
    warning "Old kernel limit already set. \n\tSkipping..."
  else
    sudo package-cleanup --oldkernels --count=2 && \
    sudo sed -i 's/(installonly_limit)=5/\1=2/' /etc/yum.conf
  fi
}

script_started
initial_setup
install_guest_additions
install_misc_utilities
misc_configuration
script_ended
