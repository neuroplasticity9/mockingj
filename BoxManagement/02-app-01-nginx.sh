#!/usr/bin/env bash
# LEMP stack configuration on CentOS 7 - Nginx

BASE_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$BASE_DIR" ]]; then BASE_DIR="$PWD"; fi
source "${BASE_DIR}/library.sh"

this_package_name="nginx"

function add_repo_for_nginx() {
  if [[ $1 != "" ]]; then repo_name="$1"; else repo_name="${this_package_name}.repo"; fi

  repo="${YUM_REPO_DIR}/${repo_name}"

  if [[ -f "${repo}" ]]
  then
    warning "${repo} already exists. Skipping..."
  else

    repo_content="# Nginx Pre-Built Packages for Mainline version
# http://nginx.org/en/linux_packages.html
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/centos/7/\$basearch/
gpgcheck=0
enabled=1"

    ( echo "${repo_content}" | sudo tee "${repo}" ) && \
      progress "YUM Repository for ${this_package_name} created at ${repo}."

  fi
}

function install_nginx() {
  sudo yum install -y nginx
}

function configure_nginx() {
  progress_title "Configuring ${this_package_name}..."

  config_path="/etc/nginx/nginx.conf"
  nginx_user="vagrant"

  occurrences=$( grep -E '^user\s+nginx;$' ${config_path} | wc -l )
  if [[ ${occurrences} == 1 ]]
  then
    sudo sed -i "s/user  nginx;/user  ${nginx_user};/" ${config_path} && \
      progress "Changed nginx user to ${nginx_user}."
  else
    warning "Could not find targetted setting or it occurs more than once in file: ${config_path}. Skipping..."
  fi

  site_available="/etc/nginx/site-available"
  site_enabled="/etc/nginx/site-enabled"

  if [[ ! -d ${site_available} ]]
  then
    sudo mkdir -p ${site_available} && \
      progress "Created directory ${site_available}"
  fi

  if [[ ! -d ${site_enabled} ]]
  then
    sudo mkdir -p ${site_enabled} && \
      progress "Created directory ${site_enabled}"
  fi
}

function setup_nginx() {
  check_service_is_active "${this_package_name}.service" && \
    "add_repo_for_${this_package_name}" && \
    "install_${this_package_name}" && \
    activate_service "${this_package_name}.service" && \
    "configure_${this_package_name}" && \
    restart_service "${this_package_name}.service"
}


script_started
setup_nginx
script_ended