#!/usr/bin/env bash
# Copy configuration files and create terminal alias
# TODO: Make this into a Symfony Console Command.


SCRIPT_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPT_DIR" ]]; then SCRIPT_DIR="$PWD"; fi

MOCKINGJ_CONF_ROOT="${HOME}/.mockingj"
VAGRANT_SHARED_FOLDER="${HOME}/MockingjShared"

function mockingjInit() {
  mkdir -p "$MOCKINGJ_CONF_ROOT" && echo "Check directory existed: $MOCKINGJ_CONF_ROOT" && \
    mkdir -p "$VAGRANT_SHARED_FOLDER" && echo "Check directory existed: $VAGRANT_SHARED_FOLDER" && \
    ( cp -i "${SCRIPT_DIR}/src/stubs/mockingj.yaml" "$MOCKINGJ_CONF_ROOT/mockingj.yaml"
      cp -i "${SCRIPT_DIR}/src/stubs/after.sh" "$MOCKINGJ_CONF_ROOT/after.sh"
      cp -i "${SCRIPT_DIR}/src/stubs/aliases" "$MOCKINGJ_CONF_ROOT/aliases" ) && \
      echo "Mockingj config folder initialised!"
}


function addAlias() {
  alias_string='alias mockingj="function __mockingj() { (cd ~/.composer/vendor/justinmoh/mockingj && vagrant \$*); unset -f __mockingj; }; __mockingj"'
  result=$( grep -E '^alias mockingj=' "${HOME}/.bash_profile" )
  if [[ ${result} = "" ]]
  then
    echo ${alias_string} >> "${HOME}/.bash_profile" && \
      echo "Terminal alias 'mockingj' added: ${alias_string}"
  else
    echo "Check terminal alias existed: ${result}"
  fi
}


mockingjInit && addAlias && \
  echo "Edit your config at: $MOCKINGJ_CONF_ROOT/mockingj.yaml" && \
  echo "use \`mockingj up\` to start your VM!"