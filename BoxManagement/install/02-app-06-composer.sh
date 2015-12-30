#!/usr/bin/env bash
# LEMP stack configuration on CentOS 7 - Composer

SCRIPT_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPT_DIR" ]]; then SCRIPT_DIR="$PWD"; fi
source "${SCRIPT_DIR}/../library.sh"

this_package_name="composer"

function add_repo_for_composer() {
  return 0
}

function install_composer() {
  installed=$( composer -V 2>/dev/null && echo 'installed' || echo '' )
  if [[ "${installed}" != "" ]]
  then
    composer self-update && \
      progress "Packages updated or already the latest version: ${this_package_name}"
  else
    curl -sS https://getcomposer.org/installer | php
      progress "Packages installed for: ${this_package_name}"
  fi
}

function preconfig_composer() {
  if [[ -f composer.phar ]]
  then
    sudo mv composer.phar /usr/local/bin/composer && \
      if [[ ! $PATH =~ '/usr/local/bin' ]]; then echo 'export PATH=$PATH:/usr/local/bin' >> ${BASH_PROFILE_PATH}; fi
  fi
}

function activate_composer() {
  return 0
}

function configure_composer() {
  # Set composer global bin path in bash_profile
  result=$( grep -E '^PATH=.*\.composer\/vendor\/bin(?::|$)' ${BASH_PROFILE_PATH} )
  if [[ "${result}" = "" ]]
  then
    result=$( grep -E '^export\s+PATH(?:\s|$)' ${BASH_PROFILE_PATH} )
    [[ "${result}" = "" ]] && echo 'export PATH' >> ${BASH_PROFILE_PATH}
    path='PATH=\$PATH:\$HOME/.composer/vendor/bin'
    perl -i -pe '/export\s+PATH/ and $_ = "'${path}'\n$_" ' ${BASH_PROFILE_PATH} && \
      progress "Composer path added into ${BASH_PROFILE_PATH}."
  else
    warning "Composer path already set in ${BASH_PROFILE_PATH}: ${result} \n\tSkipping..."
  fi

  # Disable Xdebug loading from php
  target_string='^(zend_extension=xdebug.so)$'
  substitute=';\1'
  config_path="$( ls /etc/php.d/*xdebug.ini )"
  sudo sed -i -r "s|${target_string}|${substitute}|w ${SED_LOG}" ${config_path}
  if [[ -s ${SED_LOG} ]]
  then
    modified=$( cat ${SED_LOG} )
    progress "Changed config patterned [${target_string}] to [${modified}] in ${config_path}."
  else
    warning "Could not find config pattern [${target_string}] in ${config_path}. \n\tSkipping..."
  fi

  # Set alias for php to run with Xdebug loaded explicitly
  result=$( grep -E "^alias php='php -dzend_extension=xdebug\.so'$" ${BASH_PROFILE_PATH} )
  if [[ "${result}" = "" ]]
  then
    echo "alias php='php -dzend_extension=xdebug.so'" >> ${BASH_PROFILE_PATH} && \
      progress "Alias 'php' set to load xdebug explicitly."
  else
    warning "Alias 'php' already set. \n\tSkipping..."
  fi

}

function restart_composer() {
  return 0
}

function setup_composer() {
  "add_repo_for_${this_package_name}" && \
  "install_${this_package_name}" && \
  "preconfig_${this_package_name}" && \
  "activate_${this_package_name}" && \
  "configure_${this_package_name}" && \
  "restart_${this_package_name}"
}

script_started
setup_composer
script_ended
