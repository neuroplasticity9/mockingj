#!/usr/bin/env bash
# Initial setup after insert GuestAdditions.iso in a fresh centos/7 image.

BASE_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$BASE_DIR" ]]; then BASE_DIR="$PWD"; fi
source ${BASE_DIR}/library.sh

function initial_setup() {
  progress "Preparing VM..."
  sudo yum install -y epel-release && \
    sudo yum -y upgrade && \
    sudo yum install -y gcc kernel-devel kernel-headers dkms make bzip2 perl
}

function install_guest_additions() {
  progress "Install Guest Additions"
  sudo mount /dev/sr0 /mnt && \
    sudo sh /mnt/VBoxLinuxAdditions.run && \
    sudo umount /mnt
}

script_started
initial_setup
install_guest_additions
script_ended
