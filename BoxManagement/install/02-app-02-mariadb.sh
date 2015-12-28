#!/usr/bin/env bash
# LEMP stack configuration on CentOS 7 - MariaDB

SCRIPT_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPT_DIR" ]]; then SCRIPT_DIR="$PWD"; fi
source "${SCRIPT_DIR}/../library.sh"

this_package_name="mariadb"

function add_repo_for_mariadb () {
  repo="${YUM_REPO_DIR}/mariadb.repo"

  if [[ -f "${repo}" ]]
  then
    warning "File ${repo} already exists. \n\tSkipping..."
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
  installed=$(yum list installed | grep "${this_package_name}" )
  if [[ "${installed}" != "" && "${installed}" =~ '@mariadb' ]]
  then
    sudo yum upgrade -y MariaDB-server MariaDB-client && \
      progress "Packages updated or already the latest version: ${this_package_name}"
  else
    sudo yum install -y MariaDB-server MariaDB-client && \
      progress "Packages installed for: ${this_package_name}"
  fi
}

function preconfig_mariadb() {
  return 0
}

function activate_mariadb() {
  activate_service "mariadb.service"
}

function configure_mariadb() {
  mariadb_username="mockingj"
  mariadb_password="secret"
  result=$( mysql -u"${mariadb_username}" -p"${mariadb_password}" -ANe \
    "select count(user) from mysql.user where user='${mariadb_username}';" 2>/dev/null )
  if [[ "${result}" != "0" && "${result}" != "" ]]
  then
    warning "MariaDB already configured with username [${mariadb_username}] and password [${mariadb_password}]. \n\tSkipping..."
    return 0
  fi

  # Setting up mysql_secure_installation
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

  echo "${secure_mysql}" && \
    mysql -uroot -p"${mariadb_password}" -e \
      "GRANT ALL PRIVILEGES ON *.* TO '${mariadb_username}'@'%' IDENTIFIED BY '${mariadb_password}'; FLUSH PRIVILEGES;"
}

function restart_mariadb() {
  restart_service "mariadb.service"
}

function setup_mariadb() {
  "add_repo_for_${this_package_name}" && \
  "install_${this_package_name}" && \
  "preconfig_${this_package_name}" && \
  "activate_${this_package_name}" && \
  "configure_${this_package_name}" && \
  "restart_${this_package_name}"
}

script_started
setup_mariadb
script_ended
