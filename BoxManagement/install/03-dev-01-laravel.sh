#!/usr/bin/env bash
# Install laravel 5.1 LST

SCRIPT_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPT_DIR" ]]; then SCRIPT_DIR="$PWD"; fi
source "${SCRIPT_DIR}/../library.sh"

function install_laravel() {
  # Installation directory and version
  installation_path="${HOME}/shared/laravel51"
  laravel_version="5.1.*"

  # Case if directory exists and not empty
  if [[ -d "${installation_path}" && "$( ls -A "${installation_path}" )" != "" ]]
  then
    cd ${installation_path} && composer -vv update && \
      progress "Laravel 5.1 updated at ${installation_path}"
  else
    mkdir -p "${HOME}/shared/" && \
      cd ${installation_path}/.. && \
      composer -vv create-project "laravel/laravel" "laravel51" "${laravel_version}" && \
      progress "Laravel ${laravel_version} installed at ${installation_path}."
  fi

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