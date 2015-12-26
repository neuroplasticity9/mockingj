#!/usr/bin/env bash
# LEMP stack configuration on CentOS 7

BASE_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$BASE_DIR" ]]; then BASE_DIR="$PWD"; fi
source ${BASE_DIR}/library.sh

YUM_REPO_DIR="/etc/yum.repos.d"

function post_install() {
  sudo systemctl start $1 && \
    sudo systemctl enable $1 && \
    progress "...... $1 is configured and enabled."
}

function add_nginx_mainline_repo() {
  if [[ $1 != "" ]]; then repo_name="$1"; else repo_name="nginx.repo"; fi

  repo="${YUM_REPO_DIR}/${repo_name}"

  if [[ -f "${repo}" ]]
  then
    warning "${repo} already exists. Skipping..."
  else

    content="# Nginx Pre-Built Packages for Mainline version
# http://nginx.org/en/linux_packages.html
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/centos/7/\$basearch/
gpgcheck=0
enabled=1"

    ( echo "${content}" | sudo tee "${repo}" ) && \
      progress "Nginx (mainline) repository created at ${repo}."

  fi
}

function configure_nginx() {
  nginxConfig="/etc/nginx/nginx.conf"
  runNginxAs="vagrant"

  progress "Configuring Nginx..." --bold

  occurrences=$( grep -E '^user\s+nginx;$' ${nginxConfig} | wc -l )
  if [[ ${occurrences} == 1 ]]
  then
    sudo sed -i "s/user  nginx;/user  ${runNginxAs};/" ${nginxConfig} && \
      progress "Changed nginx user to ${runNginxAs}."
  else
    warning "Could not find targetted setting or it occurs more than once in file: ${nginxConfig}. Skipping..."
  fi

  site_available="/etc/nginx/site-available"
  site_enabled="/etc/nginx/site-enabled"

  if [[ ! -d ${site_available} ]]
  then
    mkdir -p ${site_available} && \
      progress "Created directory ${site_available}"
  fi

  if [[ ! -d ${site_enabled} ]]
  then
    mkdir -p ${site_enabled} && \
      progress "Created directory ${site_enabled}"
  fi
}

function install_nginx() {
  add_nginx_mainline_repo && \
    sudo yum install -y nginx && \
    configure_nginx && post_install "nginx.service"
}

script_started
install_nginx
script_ended