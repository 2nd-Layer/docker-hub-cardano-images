#!/usr/bin/env bash
set -e

source /usr/local/lib/cardano-rt-view-set-env-variables.sh

function preExitHook () {
  exec "$@"
  echo 'Exiting...'
}

if [[ ! -f ${CNODE_RT_VIEW_CONF_FILE} ]]; then
  echo "'cardano-rt-view' config file does not exists! 'cardano-rt-view' can NOT start!!!"
  preExitHook "$@"
  exit
fi

cardano-rt-view --config ${CNODE_RT_VIEW_CONF_FILE} \
  --static ${CNODE_RT_VIEW_STATIC_FILES} \
  --port ${CNODE_RT_VIEW_PORT}