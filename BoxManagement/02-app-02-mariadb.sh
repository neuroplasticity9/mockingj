#!/usr/bin/env bash
# LEMP stack configuration on CentOS 7 - MariaDB

BASE_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$BASE_DIR" ]]; then BASE_DIR="$PWD"; fi
source ${BASE_DIR}/library.sh

this_package_name="mariadb"

function add_repo_for_mariadb () {
  if [[ $1 != "" ]]; then repo_name="$1"; else repo_name="${this_package_name}.repo"; fi

  repo="${YUM_REPO_DIR}/${repo_name}"

  if [[ -f "${repo}" ]]
  then
    warning "${repo} already exists. Skipping..."
  else

  # Repository source: https://downloads.mariadb.org/mariadb/repositories/
    repo_content="# MariaDB 10.1 CentOS repository list - created 2015-12-27 07:38 UTC
# http://mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1"

    ( echo "${repo_content}" | sudo tee "${repo}" ) && \
      progress "YUM Repository for ${this_package_name} created at ${repo}."

  fi
}

function install_mariadb() {
  sudo yum install -y MariaDB-server MariaDB-client
}

function configure_mariadb() {
  progress_title "Configuring ${this_package_name}..."

  mariadb_username="mockingj"
  mariadb_password="secret"

  secure_mysql=$(expect -c "
set timeout 3
spawn sudo mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"\r\"
expect \"Change the root password?\"
send \"y\r\"
expect \"New password:\"
send \"$mariadb_password\r\"
expect \"Re-enter new password:\"
send \"$mariadb_password\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")

  query="GRANT ALL PRIVILEGES ON *.* TO '${mariadb_username}'@'%' IDENTIFIED BY '${mariadb_password}'; FLUSH PRIVILEGES;"

  echo "${secure_mysql}" && \
    mysql -uroot -p"${mariadb_password}" -e "${query}"
}

function setup_mariadb() {
  check_service_is_active "${this_package_name}.service" && \
    "add_repo_for_${this_package_name}" && \
    "install_${this_package_name}" && \
    activate_service "${this_package_name}.service" && \
    "configure_${this_package_name}" && \
    restart_service "${this_package_name}.service"
}

script_started
setup_mariadb
script_ended
