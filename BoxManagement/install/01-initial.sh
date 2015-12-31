#!/usr/bin/env bash
# Initial setup after insert GuestAdditions.iso in a fresh centos/7 image.

SCRIPT_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPT_DIR" ]]; then SCRIPT_DIR="$PWD"; fi
source "${SCRIPT_DIR}/../library.sh"


function initial_setup() {
  progress "Upgrading system..." && \
    sudo yum install -y epel-release && \
    sudo yum -y upgrade
}

function install_guest_additions() {
  installed=$( lsmod | grep vboxguest )
  if [[ "${installed}" != "" ]]
  then
    warning "Guest Additions already installed. \n\tSkipping..."
  else
    progress "Installing Guest Additions..." && \
      sudo yum install -y gcc kernel-devel kernel-headers dkms make bzip2 perl && \
      sudo mount /dev/sr0 /mnt && \
      sudo sh /mnt/VBoxLinuxAdditions.run && \
      sudo umount /mnt
  fi
}

function install_misc_utilities() {
  installed=$( yum list installed | grep "expect" )
  if [[ "${installed}" = "" ]]
  then
    progress "Updating misc packages" && \
      sudo yum groupinstall -y "Development Tools" && \
      sudo yum install -y expect yum-utils
  else
    warning "Misc packages already installed. \n\tSkipping..."
  fi
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
  progress "Cleaning up old kernels..."
  limit=$(grep -e 'installonly_limit=2' /etc/yum.conf)
  if [[ "${limit}" = "" ]]
  then
    sudo package-cleanup --oldkernels --count=2 && \
      sudo sed -ri 's/(installonly_limit)=5/\1=2/' /etc/yum.conf && \
      progress "Kernel limit set to 2."
  else
    warning "Old kernel limit already set. \n\tSkipping..."
  fi

}

script_started
initial_setup
install_guest_additions
install_misc_utilities
misc_configuration
script_ended
