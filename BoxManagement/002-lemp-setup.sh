#!/usr/bin/env bash
# LEMP stack configuration on CentOS 7

BASE_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$BASE_DIR" ]]; then BASE_DIR="$PWD"; fi
source ${BASE_DIR}/library.sh


function post_install() {
  sudo systemctl start $1 && \
    sudo systemctl enable $1 && \
    progress "$1 Enabled."
}

function add_nginx_mainline_repo() {
  repo="/etc/yum.repos.d/nginx.repo"
  if [[ -f "${repo}" ]]; then
    warning "${repo} already exists. Skipping..."
  else
    content="# Nginx Pre-Built Packages for Mainline version
# http://nginx.org/en/linux_packages.html
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/centos/7/\$basearch/
gpgcheck=0
enabled=1"
    echo "${content}" | sudo tee "${repo}"
  fi
}

function configure_nginx() {
  nginxConfig="/etc/nginx/nginx.conf"
  runNginxAs="vagrant"
  if [[ grep -q "user  nginx;" ${nginxConfig} ]]
  then
    sudo sed -i "s/user  nginx;/user  ${runNginxAs};/" ${nginxConfig}
  else
    error_exit "Could not find relavant setting to be modified."
  fi
}