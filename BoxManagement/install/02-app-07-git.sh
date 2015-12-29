#!/usr/bin/env bash
# LEMP stack configuration on CentOS 7 - Git

SCRIPT_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPT_DIR" ]]; then SCRIPT_DIR="$PWD"; fi
source "${SCRIPT_DIR}/../library.sh"

this_package_name="git"

function add_repo_for_git() {
  return 0
}

# Installation instructions: [https://www.digitalocean.com/community/tutorials/how-to-install-git-on-centos-7]
function install_git() {
  installed=$( git --version 2>/dev/null || echo '' )
  if [[ "${installed}" != "" ]]
  then
    warning "Git has already been installed: ${installed}. \n\tSkipping..."

  else
    sudo yum install curl-devel expat-devel gettext-devel openssl-devel perl-devel zlib-devel
      progress "Packages installed for: ${this_package_name}"
  fi
}

# Source file directory: [https://www.kernel.org/pub/software/scm/git/]
function preconfig_git() {
  # Specify the version to install
  version="2.6.4"

  installed=$( git --version 2>/dev/null || echo '' )
  if [[ "${installed}" =~ "${version}" ]]
  then
    warning "Current git version is: ${installed}. \n\tSkipping..."
  else

    # Download source file
    [[ ! -f git-${version}.tar.gz ]] && curl -O https://www.kernel.org/pub/software/scm/git/git-${version}.tar.gz

    # Extract source file
    [[ -f git-${version}.tar.gz && ! -d git-${version} ]] && tar -zxf git-${version}.tar.gz

    # Compile
    [[ -d git-${version} ]] && \
      cd git-${version} && \
      make configure && \
      ./configure --prefix=/usr/local && \
      sudo make install && \
      progress "Git is compiled and now available. \n\t$(git --version)"

  fi
}

function activate_git() {
  return 0
}

function configure_git() {
  return 0
}

function restart_git() {
  return 0
}

function setup_git() {
  "add_repo_for_${this_package_name}" && \
  "install_${this_package_name}" && \
  "preconfig_${this_package_name}" && \
  "activate_${this_package_name}" && \
  "configure_${this_package_name}" && \
  "restart_${this_package_name}"
}

script_started
setup_git
script_ended
