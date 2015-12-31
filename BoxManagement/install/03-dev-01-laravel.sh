#!/usr/bin/env bash
# Install laravel 5.1 LST

SCRIPT_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPT_DIR" ]]; then SCRIPT_DIR="$PWD"; fi
source "${SCRIPT_DIR}/../library.sh"

function install_laravel() {
  # Installation directory and version
  installation_path="${HOME}/shared/laravel51"
  laravel_version="5.1.*"

#  # Case if directory exists
#  if [[ -d "${installation_path}" ]]
#  then
#    # If exist and not empty
#    if [[ ! "$( ls -A "${installation_path}" )" ]]
#    then
#      rm -rf "${installation_path}" && \
#        progress "Removed directory: ${installation_path}"
#    else
#      rm -rf "${installation_path}" && \
#        progress "Removed empty directory: ${installation_path}"
#    fi
#  fi

  mkdir -p "${HOME}/shared/" && \
  composer create-project laravel/laravel ${installation_path} ${laravel_version} && \
    progress "Laravel ${laravel_version} installed at ${installation_path}."
}

function configure_laravel() {
  return 0
}

function setup_laravel() {
  progress "Installing Laravel 5.1" && \
    install_laravel
}


script_started
setup_laravel
script_ended