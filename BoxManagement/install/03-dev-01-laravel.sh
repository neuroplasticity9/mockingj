#!/usr/bin/env bash
# Install laravel 5.1 LST

SCRIPT_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPT_DIR" ]]; then SCRIPT_DIR="$PWD"; fi
source "${SCRIPT_DIR}/../library.sh"

function install_laravel() {
  # Locate installation at /home/vagrant/shared/
  installation_dir="${HOME}/shared"
  project_name="laravel51"
  laravel_version="5.1.*"
  [[ ! -d ${installation_dir} ]] && mkdir -p ${installation_dir} && \
    progress "Directory created: ${installation_dir}"

  if [[ -d "${installation_dir}/${project_name}" && ! "$( ls -A "${installation_dir}/${project_name}" )" ]]
  then
    rm -rf "${installation_dir}/${project_name}" && \
      progress "Removed empty directory: ${installation_dir}/${project_name}"
  fi

  composer -vvv create-project laravel/laravel "${installation_dir}/${project_name}" "${laravel_version}" && \
    progress "Laravel ${laravel_version} installed at ${installation_dir}/${project_name}."
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