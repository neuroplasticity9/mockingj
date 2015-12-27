#!/usr/bin/env bash
# LEMP stack configuration on CentOS 7 - MariaDB

BASE_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$BASE_DIR" ]]; then BASE_DIR="$PWD"; fi
source ${BASE_DIR}/library.sh

this_package_name="postgresql"

function add_repo_for_postgresql () {
  repo="${YUM_REPO_DIR}/pgdg-94-redhat.repo"

  if [[ -f "${repo}" ]]
  then
    warning "${repo} already exists. Skipping..."
  else

    sudo yum install -y http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-redhat94-9.4-1.noarch.rpm && \
      progress "YUM Repository for ${this_package_name} created at ${repo}."

  fi
}

function install_postgresql() {
  sudo yum install -y postgresql94-server postgresql94-contrib && \
    sudo /usr/pgsql-9.4/bin/postgresql94-setup initdb
}

function configure_postgresql() {
  postgresql_username="mockingj"
  progress_title "Configuring ${this_package_name}..." && \
    sudo su - postgres bash -c "psql -c \"CREATE USER ${postgresql_username} WITH PASSWORD 'secret'; ALTER USER ${postgresql_username} SUPERUSER\""
}

function setup_postgresql() {
  check_service_is_active "${this_package_name}-9.4.service" && \
    "add_repo_for_${this_package_name}" && \
    "install_${this_package_name}" && \
    activate_service "${this_package_name}-9.4.service" && \
    "configure_${this_package_name}" && \
    restart_service "${this_package_name}-9.4.service"
}

script_started
setup_postgresql
script_ended
