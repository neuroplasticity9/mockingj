#!/usr/bin/env bash
# LEMP stack configuration on CentOS 7 - NodeJS

SCRIPT_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPT_DIR" ]]; then SCRIPT_DIR="$PWD"; fi
source "${SCRIPT_DIR}/../library.sh"

this_package_name="nodejs"

function add_repo_for_nodejs() {
  return 0
}

# Installation instructions: [https://github.com/nodesource/distributions#rpminstall]
function install_nodejs() {
  installed=$( rpm -qa nodejs )
  if [[ "${installed}" != "" ]]
  then
    warning "Packages for NodeJS already installed: ${installed}. \n\tSkipping..."
  else
    curl -sL https://rpm.nodesource.com/setup_5.x | sudo -E bash - && \
      sudo yum install -y nodejs && \
      progress "Packages installed for: ${this_package_name}"
  fi
}

function preconfig_nodejs() {
  sudo npm install npm -g
}

function activate_nodejs() {
  return 0
}

function configure_nodejs() {
  return 0
}

function restart_nodejs() {
  return 0
}

function setup_nodejs() {
  "add_repo_for_${this_package_name}" && \
  "install_${this_package_name}" && \
  "preconfig_${this_package_name}" && \
  "activate_${this_package_name}" && \
  "configure_${this_package_name}" && \
  "restart_${this_package_name}"
}

script_started
setup_nodejs
script_ended
