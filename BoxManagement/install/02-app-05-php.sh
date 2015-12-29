#!/usr/bin/env bash
# LEMP stack configuration on CentOS 7 - PHP

SCRIPT_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPT_DIR" ]]; then SCRIPT_DIR="$PWD"; fi
source "${SCRIPT_DIR}/../library.sh"

this_package_name="php"

# If you installed remi repo by rpm, you can delete it by:
# rpm -qa remi*
# sudo rpm -e remi{whatever it shows}

# Repository available at [http://rpms.remirepo.net/wizard/]
function add_repo_for_php() {
  repo="${YUM_REPO_DIR}/remi*.repo"
  if ( ls ${repo} 1>/dev/null 2>&1 );
  then
    warning "Files ${repo} already exist. \n\tSkipping..."
  else
    sudo yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm && \
      progress "YUM Repository for ${this_package_name} created at ${repo}."
  fi
}

function install_php() {
  sudo yum install -y --enablerepo=remi-php70 \
    php php-fpm php-mysqlnd php-pgsql \
    php-mbstring php-intl php-xml\
    php-pecl-xdebug && \
    progress "Packages have been installed / updated for: ${this_package_name}"
}

function preconfig_php() {
  return 0
}

function configure_php() {

  # Change cgi.fix_pathinfo=0 in php.ini
  target_string='^;(cgi.fix_pathinfo=)1$'
  config_path="/etc/php.ini"
  sudo sed -i -r "s/${target_string}/\10/w ${SED_LOG}" ${config_path}
  if [[ -s ${SED_LOG} ]]
  then
    modified=$( cat ${SED_LOG} )
    progress "Changed config patterned [${target_string}] to [${modified}] in ${config_path}."
  else
    warning "Could not find config pattern [${target_string}] in ${config_path}. \n\tSkipping..."
  fi

  # Change memory_limit=128M -> 512M in php.ini
  target_string='^(memory_limit\s+=\s+)128M$'
  substitute='512M'
  config_path="/etc/php.ini"
  sudo sed -i -r "s/${target_string}/\1${substitute}/w ${SED_LOG}" ${config_path}
  if [[ -s ${SED_LOG} ]]
  then
    modified=$( cat ${SED_LOG} )
    progress "Changed config patterned [${target_string}] to [${modified}] in ${config_path}."
  else
    warning "Could not find config pattern [${target_string}] in ${config_path}. \n\tSkipping..."
  fi

  # Change process user = vagrant for php-fpm
  target_string='^(user\s+=\s+)apache$'
  substitute='vagrant'
  config_path="/etc/php-fpm.d/www.conf"
  sudo sed -i -r "s|${target_string}|\1${substitute}|w ${SED_LOG}" ${config_path}
  if [[ -s ${SED_LOG} ]]
  then
    modified=$( cat ${SED_LOG} )
    progress "Changed config patterned [${target_string}] to [${modified}] in ${config_path}."
  else
    warning "Could not find config pattern [${target_string}] in ${config_path}. \n\tSkipping..."
  fi

  # Change process group = vagrant for php-fpm
  target_string='^(group\s+=\s+)apache$'
  substitute='vagrant'
  config_path="/etc/php-fpm.d/www.conf"
  sudo sed -i -r "s|${target_string}|\1${substitute}|w ${SED_LOG}" ${config_path}
  if [[ -s ${SED_LOG} ]]
  then
    modified=$( cat ${SED_LOG} )
    progress "Changed config patterned [${target_string}] to [${modified}] in ${config_path}."
  else
    warning "Could not find config pattern [${target_string}] in ${config_path}. \n\tSkipping..."
  fi

  # Change listening owner for unix socket for php-fpm
  target_string='^;(listen.owner\s+=\s+)nobody$'
  substitute='vagrant'
  config_path="/etc/php-fpm.d/www.conf"
  sudo sed -i -r "s|${target_string}|\1${substitute}|w ${SED_LOG}" ${config_path}
  if [[ -s ${SED_LOG} ]]
  then
    modified=$( cat ${SED_LOG} )
    progress "Changed config patterned [${target_string}] to [${modified}] in ${config_path}."
  else
    warning "Could not find config pattern [${target_string}] in ${config_path}. \n\tSkipping..."
  fi

  # Change listening group for unix socket for php-fpm
  target_string='^;(listen.group\s+=\s+)nobody$'
  substitute='vagrant'
  config_path="/etc/php-fpm.d/www.conf"
  sudo sed -i -r "s|${target_string}|\1${substitute}|w ${SED_LOG}" ${config_path}
  if [[ -s ${SED_LOG} ]]
  then
    modified=$( cat ${SED_LOG} )
    progress "Changed config patterned [${target_string}] to [${modified}] in ${config_path}."
  else
    warning "Could not find config pattern [${target_string}] in ${config_path}. \n\tSkipping..."
  fi

  # Change listening mode for unix socket for php-fpm
  target_string='^;(listen.mode\s+=\s+)0660$'
  substitute='0666'
  config_path="/etc/php-fpm.d/www.conf"
  sudo sed -i -r "s|${target_string}|\1${substitute}|w ${SED_LOG}" ${config_path}
  if [[ -s ${SED_LOG} ]]
  then
    modified=$( cat ${SED_LOG} )
    progress "Changed config patterned [${target_string}] to [${modified}] in ${config_path}."
  else
    warning "Could not find config pattern [${target_string}] in ${config_path}. \n\tSkipping..."
  fi

  # Configure Xdebug
#  target_string='^; Enable xdebug extension module$'
#  substitute=''
#  config_path="$( ls /etc/php.d/*xdebug.ini )"
#  sudo sed -i -r "s|${target_string}|\1${substitute}|w ${SED_LOG}" ${config_path}
#  if [[ -s ${SED_LOG} ]]
#  then
#    modified=$( cat ${SED_LOG} )
#    progress "Changed config patterned [${target_string}] to [${modified}] in ${config_path}."
#  else
#    warning "Could not find config pattern [${target_string}] in ${config_path}. \n\tSkipping..."
#  fi

  # Configure Xdebug
  config_path="$( ls /etc/php.d/*xdebug.ini )"
  content='; Enable xdebug extension module
zend_extension=xdebug.so

xdebug.remote_enable=on
xdebug.remote_connect_back=on
xdebug.remote_port=10000

; see http://xdebug.org/docs/all_settings'

  current_content="$(cat ${config_path})"
  if [[ ! "${current_content}" =~ ${content} ]]
  then
    echo "${content}" | sudo tee ${config_path} && \
      progress "Xdebug config has been set to default values in ${config_path}."
  else
    warning "Xdebug config is already the default values in ${config_path}. \n\tSkipping..."
  fi

}

function activate_php() {
  activate_service "php-fpm.service"
}

function restart_php() {
  restart_service "php-fpm.service"
}

function setup_php() {
  "add_repo_for_${this_package_name}" && \
  "install_${this_package_name}" && \
  "preconfig_${this_package_name}" && \
  "activate_${this_package_name}" && \
  "configure_${this_package_name}" && \
  "restart_${this_package_name}"
}


script_started
setup_php
script_ended