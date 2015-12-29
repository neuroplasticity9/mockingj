#!/usr/bin/env bash
# LEMP stack configuration on CentOS 7 - Nginx

SCRIPT_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPT_DIR" ]]; then SCRIPT_DIR="$PWD"; fi
source "${SCRIPT_DIR}/../library.sh"

this_package_name="nginx"

function add_repo_for_nginx() {
  repo="${YUM_REPO_DIR}/nginx.repo"
  if [[ -f "${repo}" ]]
  then
    warning "File ${repo} already exists. \n\tSkipping..."
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
  installed=$(yum list installed | grep "${this_package_name}" )
  if [[ "${installed}" != "" && "${installed}" =~ '@nginx' ]]
  then
    sudo yum upgrade -y nginx && \
      progress "Packages updated or already the latest version: ${this_package_name}"
  else
    sudo yum install -y nginx && \
      progress "Packages installed for: ${this_package_name}"
  fi
}

function preconfig_nginx() {
  return 0
}

function activate_nginx() {
  activate_service "nginx.service"
}

function configure_nginx() {
  # Change process user for nginx
  target_string='^(user\s+)nginx;$'
  substitute='vagrant;'
  config_path="/etc/nginx/nginx.conf"
  sudo sed -i -r "s|${target_string}|\1${substitute}|w ${SED_LOG}" ${config_path}
  if [[ -s ${SED_LOG} ]]
  then
    modified=$( cat ${SED_LOG} )
    progress "Changed config patterned [${target_string}] to [${modified}] in ${config_path}."
  else
    warning "Could not find config pattern [${target_string}] in ${config_path}. \n\tSkipping..."
  fi

  # Add site-available & site-enabled directories
  required_dir="/etc/nginx/site-available /etc/nginx/site-enabled"
  for dir in ${required_dir}
  do
    if [[ -d ${dir} ]]
    then
      warning "Directory ${dir} already exist. \n\tSkipping..."
    else
      sudo mkdir -p ${dir} && \
      progress "Created directory: ${dir}"
    fi
  done

  # Read site settings from site-enabled directory
  target_string='^(\s*)(include\s+/etc/nginx/conf\.d/\*\.conf;\n+?\s*?)(})$'
  substitute='${1}include /etc/nginx/site-enabled/\*;${1}server_names_hash_bucket_size 64;\n'
  config_path='/etc/nginx/nginx.conf'
  sudo perl -i -pe 'BEGIN{undef $/;} s|'"${target_string}"'|$1$2'"${substitute}"'$3|m && $M++;END{exit 1 unless $M>0}' ${config_path}
  if [[ $? == 0 ]]
  then
    progress 'Added config to read site from site-enabled directory in '"${config_path}"'.'
  else
    warning 'Could not find the specified config pattern or already configured in '"${config_path}"'. \n\tSkipping...'
  fi

}

function restart_nginx() {
  restart_service "nginx.service"
}

function setup_nginx() {
  "add_repo_for_${this_package_name}" && \
  "install_${this_package_name}" && \
  "preconfig_${this_package_name}" && \
  "activate_${this_package_name}" && \
  "configure_${this_package_name}" && \
  "restart_${this_package_name}"
}


script_started
setup_nginx
script_ended