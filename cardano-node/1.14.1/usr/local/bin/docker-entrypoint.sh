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
elif [[ ! -f ${CARDANO_NODE_CONF_FILE} ]]; then
  echo "'cardano-node' config file does not exists! 'cardano-node' can NOT start!!!"
  preExitHook "$@"
  exit
elif [[ ! -f ${CARDANO_NODE_TOPOLOGY_FILE} ]]; then
  echo "'cardano-node' topology file does not exists! 'cardano-node' can NOT start!!!"
  preExitHook "$@"
  exit
elif [[ ! -d ${CARDANO_NODE_DB_PATH} ]]; then
  echo "'cardano-node' database directory does not exists! 'cardano-node' can NOT start!!!"
  preExitHook "$@"
  exit
fi

if [[ ! -f ${CARDANO_NODE_SECRET_FILE} ]]; then
  echo "'cardano-node' secret file not found! 'cardano-node' will start in a passive mode!"
  echo "Config file: ${CARDANO_NODE_CONF_FILE}"
  echo "Topology file: ${CARDANO_NODE_TOPOLOGY_FILE}"
  echo "Database path: ${CARDANO_NODE_DB_PATH}"
  echo "Socket path: ${CARDANO_NODE_SOCKET}"
  echo "Node port: ${CARDANO_NODE_PORT}"
  cardano-node run \
    --config ${CARDANO_NODE_CONF_FILE} \
    --topology ${CARDANO_NODE_TOPOLOGY_FILE} \
    --database-path ${CARDANO_NODE_DB_PATH} \
    --socket-path ${CARDANO_NODE_SOCKET_PATH} \
    --port ${CARDANO_NODE_PORT}

else
  echo "'cardano-node' secret file found! 'cardano-node' will start in a slot leader mode!"
  cardano-node run \
    --config ${CARDANO_NODE_CONF_FILE} \
    --topology ${CARDANO_NODE_TOPOLOGY_FILE} \
    --database-path ${CARDANO_NODE_DB_PATH} \
    --socket-path ${CARDANO_NODE_SOCKET_PATH} \
    --port ${CARDANO_NODE_PORT}
fi
