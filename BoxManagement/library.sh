#!/usr/bin/env bash

ROOT_DIR=$(dirname $(readlink -f $BASH_SOURCE))

BASE_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$BASE_DIR" ]]; then BASE_DIR="$PWD"; fi

# this script name
LIBNAME=$(basename "${BASH_SOURCE[0]}")

# the script name that sourced this file
PROGNAME=$(basename "${0}")

################################################################################
#   ERRORS AND TRAPS                                                           #
################################################################################


# Remove all .tmp files
function clean_up() {
  rm -rf ${ROOT_DIR}/*.tmp
  tput sgr0
}


function redirected_stderr() {
  # TODO: How to handle streamed text with multiple lines?
  if [[ -e ${BASE_DIR}/err.tmp ]]; then
    error_message=$(cat ${BASE_DIR}/err.tmp)
    format_output "  ${error_message}" --red --bold
  fi
}

# Print message when unexpected script termination occurs.
function unexpected_termination() {
  trap : 0

  redirected_stderr
  format_output "Unexpected script termination occurs. Exiting..." --red --bold

  clean_up
  exit 1
}

# Print message when script error occurs.
function termination_on_error() {
  redirected_stderr
  format_output "Script terminated on error. Exiting..." --red --bold
  clean_up

  trap : 0
  exit 1
}

# Manually exit with error message.
# Usage : error_exit [ message ]
function error_exit() {
  format_output "  ${1:-"Unknown Error"}" --red --bold
  clean_up

  trap : 0
  exit 1
}

function warning_exit() {
  format_output "  ${1:-"Unknown Error"}" --yellow --bold
  clean_up

  trap : 0
  exit 1
}

function clear_format() {
  tput sgr0
}

set -e
trap termination_on_error EXIT
trap unexpected_termination SIGHUP SIGINT SIGQUIT SIGTERM
trap clear_format EXIT

################################################################################
#   OUTPUT ATTRIBUTES AND COLOURS                                              #
################################################################################

ATTR_BOLD=$(tput bold)
ATTR_UNDERLINE=$(tput sgr 0 1)
#ATTR_UNDERLINE_SET=$(tput smul)
#ATTR_UNDERLINE_UNSET=$(tput rmul)
ATTR_BLINK=$(tput blink)
ATTR_RESET=$(tput sgr0)

COLOR_BLACK=$(tput setaf 0)
COLOR_RED=$(tput setaf 1)
COLOR_GREEN=$(tput setaf 2)
COLOR_YELLOW=$(tput setaf 3)
COLOR_BLUE=$(tput setaf 4)
COLOR_MAGENTA=$(tput setaf 5)
COLOR_CYAN=$(tput setaf 6)
COLOR_WHITE=$(tput setaf 7)
COLOR_RESET=$(tput sgr0)

CLEAR_FONT_FORMAT="${ATTR_RESET}"

font_attr=""   # 0
font_color="" # 00
font_format="${ATTR_RESET}" # \033[0m


function set_font_attr() {
  case $1 in
    --normal )
      font_attr="${ATTR_RESET}" ;;
    --bold )
      font_attr="${ATTR_BOLD}" ;;
    --underline )
      font_attr="${ATTR_UNDERLINE}" ;;
    --blink )
      font_attr="${ATTR_BLINK}" ;;
  esac
}


function set_font_color() {
  case $1 in
    --black )
      font_color="${COLOR_BLACK}" ;;
    --red )
      font_color="${COLOR_RED}" ;;
    --green )
      font_color="${COLOR_GREEN}" ;;
    --yellow )
      font_color="${COLOR_YELLOW}" ;;
    --blue )
      font_color="${COLOR_BLUE}" ;;
    --magenta )
      font_color="${COLOR_MAGENTA}" ;;
    --cyan )
      font_color="${COLOR_CYAN}" ;;
    --white )
      font_color="${COLOR_WHITE}" ;;
  esac
}


function set_font_format() {
  tput sgr0
  font_format="${font_attr}${font_color}"
}

function reset_font_format() {
  font_attr=""
  font_color=""
  font_format="${ATTR_RESET}"
  tput sgr0
}

# Output text with attribute and color format.
# Usage: format_echo <message>
#   [ black | red | green | yellow | blue | magenta | cyan | white ] |
#   [ normal | bold | underline | blink ]
function format_output() {
  # Set $1 as the message
  if [[ $1 = "" ]]; then
    error_exit "{$FUNCNAME}: <message> is required. $@"
  fi
  message=$1
  shift

  # Process flags and set attributes and colors
  while [ "$1" != "" ]; do
    case $1 in
      --normal | --bold | --underline | --blink )
        set_font_attr $1
        shift
        ;;
      --black | --red | --green | --yellow | --blue | --magenta | --cyan | --white )
        set_font_color $1
        shift
        ;;
      * )
        shift
        ;;
    esac
  done

  set_font_format
  printf "${font_format}${message}${CLEAR_FONT_FORMAT}\n"
  reset_font_format
}


################################################################################
#   Public Domain                                                              #
################################################################################

function progress_title() {
  format_output "  $1" --green --bold
}

function progress() {
  format_output "  $1" --green
}

function warning() {
  format_output "  $1" --yellow
}


function script_started() {
  format_output "${PROGNAME}: Started..." --bold --blue
}

function script_ended() {
  format_output "${PROGNAME}: Completed..." --blue
  clean_up

  trap : 0
  exit 1
}


################################################################################
#   Package Installation Globals                                               #
################################################################################

YUM_REPO_DIR="/etc/yum.repos.d"
SED_LOG="${ROOT_DIR}/sed-output.tmp"

function add_manageable_service() {
  [[ "$1" = "" ]] && error_exit "Scripting error: ${FUNCNAME} requires argument 1 - an installed service name."

  installed=$(systemctl list-units | grep $1)
  [[ "${installed}" = "" ]] && error_exit "Scripting error: ${FUNCNAME} requires argument 1 - an installed service name."

  log_file="${ROOT_DIR}/manageable-services-list"
  [[ ! -f "${log_file}" ]] && touch ${log_file}

  service_added=0
  for service in $(cat ${log_file})
  do
    [[ ${service} == $1 ]] && service_added=1
  done

  if [[ ${service_added} != 1 ]]
  then
    echo "$1" >> ${log_file} &&
      progress "\"$1\" : added into ${log_file}"
#  else
#    warning "Already exist in ${log_file} : $1. Skipping..."
  fi
}

function activate_service() {
  if [[ "$1" = "" ]]; then error_exit "Scripting error: ${FUNCNAME} requires 1 argument - service name"; fi
  sudo systemctl start $1 && \
    sudo systemctl enable $1 && \
    progress "Service activated: $1"
    add_manageable_service $1
}

function restart_service() {
  if [[ "$1" = "" ]]; then error_exit "Scripting error: ${FUNCNAME} requires 1 argument - service name"; fi
  sudo systemctl restart $1 && \
    progress "Service restarted: $1"
}

function check_service_is_active() {
  if [[ "$1" = "" ]]; then error_exit "Scripting error: ${FUNCNAME} requires 1 argument - service name"; fi
  status=$(systemctl is-active $1 )
  if [[ "${status}" = "active" ]]; then warning_exit "Service already active. Exiting..."; fi
}

function substitute_or_print_warning() {
  if [[ $# != 3 ]]; then error_exit "Scripting error: ${FUNCNAME} requires 3 arguments - target, substitute and path"; fi
  target_string="$1"
  substitute="$2"
  file_path="$3"
  occurrences=$( grep -E ${target_string} ${file_path} | wc -l )
  if [[ ${occurrences} == 1 ]]
  then
    sudo sed -i -r "s/${target_string}/\10/" ${file_path} && \
      progress "Changed configuration [${target_string}] to [${substitute}]"
  else
    warning "Could not find config pattern [${target_string}] in ${file_path}. \n\tSkipping..."
  fi

}

# Credits to Nublall@stackoverflow.com [http://stackoverflow.com/a/25054222/4520373]
function watch_dir() {
  if [[ "$1" = "" ]]; then error_exit "Scripting error: ${FUNCNAME} requires argument 1 - directory watch stage [ start | end ]"; fi

  case $1 in
    --start )
      # blah blah blah
      ;;
    --end )
      # blah blah blah
      ;;
    * )
      error_exit "Scripting error: ${FUNCNAME} requires argument 1 - directory watch stage [ start | end ]"
  esac

  shift
  if [[ "$1" = "" ]]; then error_exit "Scripting error: ${FUNCNAME} requires argument 2 - directory path";
  elif [[ ! -d $1 ]]; then error_exit "${FUNCNAME}: Path $1 does not exist."; fi

  # Directory you want to watch
  watch_dir="$1"
  # Name of the file that will keep the list of the files when you last checked it
  last_dir="${watch_dir}/last_dir_content.tmp"
  # Name of the file that will keep the list of the files you are checking now
  curr_dir="${watch_dir}/curr_dir_content.tmp"

  # The first time we create the log file
  touch "${last_dir}"

  find "${watch_dir}" -type f > "${curr_dir}"

  diff "${last_dir}" "${curr_dir}" > /dev/null 2>&1

  # If there is no difference exit
  if [ $? -eq 0 ]
  then
    echo "No changes"
  else
    # Else, list the files that changed
    echo "List of new files"
    diff $last_dir $curr_dir | grep '^>'
    echo "List of files removed"
    diff $last_dir $curr_dir | grep '^<'

    # Lastly, move CURRENT to LAST
    mv $curr_dir $last_dir
  fi
}