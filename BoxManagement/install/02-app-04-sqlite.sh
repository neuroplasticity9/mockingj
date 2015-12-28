#!/usr/bin/env bash
# LEMP stack configuration on CentOS 7 - Sqlite3

SCRIPT_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPT_DIR" ]]; then SCRIPT_DIR="$PWD"; fi
source "${SCRIPT_DIR}/../library.sh"

this_package_name="sqlite"

function add_repo_for_sqlite() {
  return 0
}

function install_sqlite() {
  installed=$(yum list installed | grep "${this_package_name}" )
  if [[ "${installed}" != "" && "${installed}" =~ '@/sqlite' ]]
  then
    sudo yum upgrade -y sqlite && \
      progress "Packages updated or already the latest version: ${this_package_name}"
  else
    sudo yum install -y ftp://rpmfind.net/linux/fedora/linux/updates/23/x86_64/s/sqlite-3.9.2-1.fc23.x86_64.rpm && \
      progress "Packages installed for: ${this_package_name}"
  fi
}

function preconfig_sqlite() {
  return 0
}

function activate_sqlite() {
  return 0
}

function configure_sqlite() {
  return 0
}

function restart_sqlite() {
  return 0
}

function setup_sqlite() {
  check_service_is_active "${this_package_name}.service" && \
    "add_repo_for_${this_package_name}" && \
    "install_${this_package_name}" && \
    "preconfig_${this_package_name}" && \
    "activate_${this_package_name}" && \
    "configure_${this_package_name}" && \
    "restart_${this_package_name}"
}

script_started
setup_sqlite
script_ended
