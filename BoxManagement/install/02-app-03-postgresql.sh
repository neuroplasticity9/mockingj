#!/usr/bin/env bash
# LEMP stack configuration on CentOS 7 - Postgresql

SCRIPT_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPT_DIR" ]]; then SCRIPT_DIR="$PWD"; fi
source "${SCRIPT_DIR}/../library.sh"

this_package_name="postgresql"

# Available packages: [http://yum.postgresql.org/repopackages.php]
function add_repo_for_postgresql () {
  repo="${YUM_REPO_DIR}/pgdg-94-centos.repo"
  if [[ -f "${repo}" ]]
  then
    warning "File ${repo} already exists. \n\tSkipping..."
  else
    sudo yum install -y http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-centos94-9.4-2.noarch.rpm && \
      progress "YUM Repository for ${this_package_name} created at ${repo}."
  fi
}

# Installation instruction: [http://www.postgresql.org/download/linux/redhat/]
function install_postgresql() {

  installed=$( yum list installed | grep "${this_package_name}" )
  if [[ "${installed}" != "" && "${installed}" =~ '@pgdg94' ]]
  then
    sudo yum upgrade -y postgresql94-server postgresql94-contrib && \
      progress "Packages updated or already the latest version: ${this_package_name}"
  else
    sudo yum install -y postgresql94-server postgresql94-contrib && \
      progress "Packages installed for: ${this_package_name}"
  fi

}

function preconfig_postgresql() {
  result=$( sudo /usr/pgsql-9.4/bin/postgresql94-setup initdb )
  if [[ "${result}" =~ 'Data directory is not empty!' ]]
  then
    warning "\`postgresql94-setup initdb\` had already been configured. \n\tSkipping..."
  fi
}

function activate_postgresql() {
  activate_service "postgresql-9.4.service"
}

function configure_postgresql() {
  postgresql_username="mockingj"
  result=$( sudo su - postgres bash -c "psql -tAc \"SELECT 1 FROM pg_roles WHERE rolname='${postgresql_username}'\"" )
  if [[ "${result}" != "" ]]
  then
    warning "PostgreSQL already has role [${postgresql_username}] configured. \n\tSkipping..."
  else
    sudo su - postgres bash -c "psql -c \"CREATE USER ${postgresql_username} WITH PASSWORD 'secret'; ALTER USER ${postgresql_username} SUPERUSER\"" && \
      progress "Created role [${postgresql_username}]: ${this_package_name}"
  fi
}

function restart_postgresql() {
  restart_service "postgresql-9.4.service"
}

function uninstall_postgresql() {
  sudo yum remove -y postgresql94* && \
    sudo rm -rf "${YUM_REPO_DIR}/pgdg-94-centos.repo"
}

function setup_postgresql() {
  "add_repo_for_${this_package_name}" && \
  "install_${this_package_name}" && \
  "preconfig_${this_package_name}" && \
  "activate_${this_package_name}" && \
  "configure_${this_package_name}" && \
  "restart_${this_package_name}"
}

script_started
setup_postgresql
script_ended
