#!/usr/bin/env bash

BASE_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$BASE_DIR" ]]; then BASE_DIR="$PWD"; fi

PROGNAME=$(basename $0)


################################################################################
#   ERRORS AND TRAPS                                                           #
################################################################################


# Remove all .tmp files
function clean_up() {
  rm -rf ${BASE_DIR}/*.tmp
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

  trap : 0

  redirected_stderr

  format_output "Script terminated on error. Exiting..." --red --bold

  clean_up
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


trap termination_on_error EXIT
trap unexpected_termination SIGHUP SIGINT SIGQUIT SIGTERM
set -e


################################################################################
#   OUTPUT ATTRIBUTES AND COLOURS                                              #
################################################################################

ATTR_BOLD=$(tput bold)
ATTR_UNDERLINE_SET=$(tput smul)
ATTR_UNDERLINE_UNSET=$(tput rmul)
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
COLOR_RESET=$(tput setaf 9)

CLEAR_FONT_FORMAT="${ATTR_RESET}"

font_attr="${ATTR_RESET}"   # 0
font_color="${COLOR_RESET}" # 00
font_format="${ATTR_RESET}" # \033[0m


function set_font_attr() {
  case $1 in
    --normal )
      font_attr=${ATTR_RESET} ;;
    --bold )
      font_attr=${ATTR_BOLD} ;;
#    --underline )
#      font_attr=${ATTR_UNDERLINE_SET} ;;
    --blink )
      font_attr=${ATTR_BLINK} ;;
  esac
}


function set_font_color() {
  case $1 in
    --black )
      font_color=${COLOR_BLACK} ;;
    --red )
      font_color=${COLOR_RED} ;;
    --green )
      font_color=${COLOR_GREEN} ;;
    --yellow )
      font_color=${COLOR_YELLOW} ;;
    --blue )
      font_color=${COLOR_BLUE} ;;
    --magenta )
      font_color=${COLOR_MAGENTA} ;;
    --cyan )
      font_color=${COLOR_CYAN} ;;
    --white )
      font_color=${COLOR_WHITE} ;;
  esac
}


function set_font_format() {

  if [[ ${font_attr} != "" ]]; then
    attr=${font_attr}
  else
    attr="0"
  fi

  if [[ ${font_color} != "" ]]; then
    color="${font_color}"
  fi

  font_format="${attr}${color}"
}

function reset_font_format() {
  font_attr="0"
  font_color="00"
  font_format=${CLEAR_FONT_FORMAT}
}

# Output text with attribute and color format.
function format_output() {
  # format_echo <message>
  #   [ black | red | green | yellow | blue | magenta | cyan | white ] |
  #   [ normal | bold | underline | blink ]

  if [[ $1 = "" ]]; then
    error_exit "{$FUNCNAME}: <message> is required. $@"
  fi

  message=$1
  shift

  while [ "$1" != "" ]; do
    case $1 in
      --normal | --bold | --underline | --blink )
        font_attr=$1
        shift
        ;;
      --black | --red | --green | --yellow | --blue | --magenta | --cyan | --white )
        font_color=$1
        shift
        ;;
      * )
        shift
        ;;
    esac
  done

  set_font_attr ${font_attr}
  set_font_color ${font_color}

  set_font_format

  echo -e "${font_format}${message}${CLEAR_FONT_FORMAT}"

  reset_font_format
}


################################################################################
#   Public Domain                                                              #
################################################################################

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
