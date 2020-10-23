#!/bin/bash

set -e

CURRENT_TIME=$(date +%s)
CONTAINER_START_TIME=$(stat --format %X /proc/1/)
CONTAINER_UPTIME=$((${CURRENT_TIME} - ${CONTAINER_START_TIME}))

CNODE_RT_VIEW_USER_HOME=$HOME

function generateRTViewConfig () {
  echo "
rotation: null
defaultBackends:
- KatipBK
setupBackends:
- KatipBK
- LogBufferBK
- TraceAcceptorBK
hasPrometheus: null
hasGraylog: null
hasGUI: null
traceForwardTo: null
traceAcceptAt:
- remoteAddr:
    tag: RemotePipe
    contents: /run/user/1000/rt-view-pipes/node-1
  nodeName: node-1
- remoteAddr:
    tag: RemotePipe
    contents: /run/user/1000/rt-view-pipes/node-2
  nodeName: node-2
- remoteAddr:
    tag: RemotePipe
    contents: /run/user/1000/rt-view-pipes/node-3
  nodeName: node-3
defaultScribes:
- - StdoutSK
  - stdout
options:
  mapBackends:
    cardano-rt-view.acceptor:
    - LogBufferBK
    - kind: UserDefinedBK
      name: ErrorBufferBK
setupScribes:
- scMaxSev: Emergency
  scName: stdout
  scRotation: null
  scMinSev: Notice
  scKind: StdoutSK
  scFormat: ScText
  scPrivacy: ScPublic
hasEKG: null
forwardDelay: null
minSeverity: Info
  " > ${CNODE_RT_VIEW_USER_HOME}etc/config.yaml
}

generateRTViewConfig

if [ -f ${CNODE_RT_VIEW_USER_HOME}etc/config.json ]; then
  CNODE_RT_VIEW_CONF_FILE=${CNODE_RT_VIEW_USER_HOME}etc/config.json
  CNODE_CONF_TYPE="json"
elif [ -f ${CNODE_RT_VIEW_USER_HOME}etc/config.yaml ]; then
  CNODE_RT_VIEW_CONF_FILE=${CNODE_RT_VIEW_USER_HOME}etc/config.yaml
  CNODE_RT_VIEW_CONF_TYPE="yaml"
fi

: ${CNODE_RT_VIEW_PORT:=${CNODE_PORT:-8080}}
: ${CNODE_RT_VIEW_STATIC_FILES:=${CNODE_RT_VIEW_STATIC_FILES:-"/usr/local/share/cardano-rt-view/static/"}}

: ${CNODE_RT_VIEW_MAX_STARTUP_TIME:=${CNODE_MAX_STARTUP_TIME:-20}}
: ${CNODE_RT_VIEWMAX_FAULT_UPTIME:=${CNODENODE_MAX_FAULT_UPTIME:-600}}

export LC_ALL=C.UTF-8

set +e