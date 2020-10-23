#!/bin/bash

set -e

CURRENT_TIME=$(date +%s)
CONTAINER_START_TIME=$(stat --format %X /proc/1/)
CONTAINER_UPTIME=$((${CURRENT_TIME} - ${CONTAINER_START_TIME}))

CNODE_RT_VIEW_USER_HOME=$HOME
if [ -f ${CNODE_RT_VIEW_USER_HOME}etc/config.json ]; then
  CNODE_RT_VIEW_CONF_FILE=${CNODE_RT_VIEW_USER_HOME}etc/config.json
  CNODE_CONF_TYPE="json"
elif [ -f ${CNODE_RT_VIEW_USER_HOME}etc/config.yaml ]; then
  CNODE_RT_VIEW_CONF_FILE=${CNODE_RT_VIEW_USER_HOME}etc/config.yaml
  CNODE_RT_VIEW_CONF_TYPE="yaml"
fi

: ${CNODE_RT_VIEW_PORT:=${CNODE_PORT:-8080}}

: ${CNODE_RT_VIEW_MAX_STARTUP_TIME:=${CNODE_MAX_STARTUP_TIME:-20}}
: ${CNODE_RT_VIEWMAX_FAULT_UPTIME:=${CNODENODE_MAX_FAULT_UPTIME:-600}}

set +e