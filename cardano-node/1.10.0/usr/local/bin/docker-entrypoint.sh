#!/usr/bin/env bash
set -e

source /usr/local/lib/cardano-node-set-env-variables.sh

function preExitHook () {
  exec "$@"
  echo 'Exiting...'
}

if [[ ! -f ${GENESIS_FILE} ]]; then
  echo 'Genesis file does not exist! 'cardano-node' can NOT start!!!'
  preExitHook "$@"
  exit
else
  GENESIS_HASH=$(cat ${GENESIS_FILE})
  echo "Genesis hash set to ${GENESIS_HASH}!"
fi

if [[ ! -f ${CARDANO_NODE_CONF_FILE} ]]; then
  echo "'cardano-node' config file does not exists! 'cardano-node' can NOT start!!!"
  preExitHook "$@"
  exit
else
  if [[ ! -f ${CARDANO_NODE_SECRET_FILE} ]]; then
    echo "'cardano-node' secret file not found! 'cardano-node' will start in a passive mode!"
    cardano-node run \
      --config ${CARDANO_NODE_CONF_FILE} \
      --database-path ${CARDANO_NODE_DB_PATH} \
      --port ${CARDANO_NODE_PORT} \
      --topology ${CARDANO_NODE_TOPOLOGY_FILE}
  else
    echo "'cardano-node' secret file found! 'cardano-node' will start in a slot leader mode!"
    cardano-node run \
      --config ${CARDANO_NODE_CONF_FILE} \
      --database-path ${CARDANO_NODE_DB_PATH} \
      --port ${CARDANO_NODE_PORT} \
      --topology ${CARDANO_NODE_TOPOLOGY_FILE}
  fi
fi
