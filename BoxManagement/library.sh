#!/usr/bin/env bash

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
  rm -rf ${BASE_DIR}/*.tmp
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

function activate_service() {
  if [[ "$1" = "" ]]; then error_exit "Scripting error: ${FUNCNAME} requires 1 argument - service name"; fi
  sudo systemctl start $1 && \
    sudo systemctl enable $1 && \
    progress "...... $1 is configured and enabled."
}

function restart_service() {
  if [[ "$1" = "" ]]; then error_exit "Scripting error: ${FUNCNAME} requires 1 argument - service name"; fi
  sudo systemctl restart $1 && \
    progress "...... $1 has been restarted."
}

function check_service_is_active() {
  if [[ "$1" = "" ]]; then error_exit "Scripting error: ${FUNCNAME} requires 1 argument - service name"; fi
  status=$(systemctl is-active $1 )
  if [[ "${status}" = "active" ]]; then warning_exit "Service already active. Exiting..."; fi
}
