#!/usr/bin/env bash
#
# Get vagrant insecure public key and completely replace content of
# ~/.ssh/authorized_keys.

SCRIPT_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPT_DIR" ]]; then SCRIPT_DIR="$PWD"; fi
source "${SCRIPT_DIR}/../library.sh"

SSH_FOLDER="/home/vagrant/.ssh"
SSH_AUTH="${SSH_FOLDER}/authorized_keys"

function get_vagrant_key_from() {
  if [[ "$1" = "" ]]; then
    error_exit "{$FUNCNAME} require one argument."
  fi

  if [[ "$1" = "local" ]]; then
    get_local_vagrant_key
    return
  fi

  if [[ $1 = "remote" ]]; then
    get_remote_vagrant_key
    return
  fi

  error_exit "{$FUNCNAME} argument $1 is not supported. Try [local|remote]"
}

function get_local_vagrant_key() {
  echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key' \
    > ${SSH_AUTH} && \
    progress "Insecure public key copied into ${SSH_AUTH} from local source."
}

function get_remote_vagrant_key() {
  #wget --no-check-certificate https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub -O /home/vagrant/.ssh/authorized_keys
  curl -Lk https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub -o ${SSH_AUTH} && \
    progress "Insecure public key copied into ${SSH_AUTH} from remote source."
}

function set_folders_permission() {
  chmod 700 ${SSH_FOLDER} && \
    progress "Folder permission changed to 700: $SSH_FOLDER" && \
    chmod 600 ${SSH_FOLDER}/authorized_keys && progress "File permission changed to 600: $SSH_AUTH"
}

function main() {
  if [[ ! -d ${SSH_FOLDER} ]]; then
    mkdir -p ${SSH_FOLDER}
  fi
  get_vagrant_key_from $1
  set_folders_permission
}

script_started
main $1 2>${ROOT_DIR}/err.tmp
script_ended