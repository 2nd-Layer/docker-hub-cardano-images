#!/bin/bash

set -e

CURRENT_TIME=$(date +%s)
CONTAINER_START_TIME=$(stat --format %X /proc/1/)
CONTAINER_UPTIME=$((${CURRENT_TIME} - ${CONTAINER_START_TIME}))

CNODE_USER_HOME=$HOME
if [ -f ${CNODE_USER_HOME}etc/genesis.json ]; then
  GENESIS_FILE=${CNODE_USER_HOME}etc/genesis.json
fi

if [ -f ${CNODE_USER_HOME}etc/topology.json ]; then
  CNODE_TOPOLOGY_FILE=${CNODE_USER_HOME}etc/topology.json
fi

if [ -f ${CNODE_USER_HOME}etc/config.json ]; then
  CNODE_CONF_FILE=${CNODE_USER_HOME}etc/config.json
  CNODE_CONF_TYPE="json"
elif [ -f ${CNODE_USER_HOME}etc/config.yaml ]; then
  CNODE_CONF_FILE=${CNODE_USER_HOME}etc/config.yaml
  CNODE_CONF_TYPE="yaml"
fi
if [[ -z ${CNODE_NODE_TYPE+x} ]]; then
  if [ -f ${CNODE_USER_HOME}etc/secrets/node_secret.yaml ]; then
    CNODE_SECRET_FILE=${CNODE_USER_HOME}etc/secrets/node_secret.yaml
    CNODE_NODE_TYPE="leader"
    CNODE_POOL_ID=$(grep 'node_id' ${JORM_SECRET_FILE} | awk '{print $2}')
  else
    CNODE_NODE_TYPE="relay"
  fi
else
  CNODE_NODE_TYPE=${CNODE_NODE_TYPE}
fi

: ${CNODE_DB_PATH:=${CNODE_DB_PATH:-${CNODE_USER_HOME}/storage/}}
: ${CNODE_PORT:=${CNODE_PORT:-9000}}
: ${CNODE_SOCKET_PATH:=${CNODE_SOCKET_PATH:-/var/run/cardano/cardano-node.sock}}

: ${CNODE_MAX_STARTUP_TIME:=${CNODE_MAX_STARTUP_TIME:-20}}
: ${CNODE_MAX_FAULT_UPTIME:=${CNODENODE_MAX_FAULT_UPTIME:-600}}
: ${POOLTOOL_MAX_BLOCK_DELTA:=${POOLTOOL_MAX_BLOCK_DELTA:-5}}

export CARDANO_NODE_SOCKET_PATH=${CNODE_SOCKET_PATH}

set +e