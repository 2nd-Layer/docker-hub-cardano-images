#!/bin/bash

if ! [[ -z ${POOLTOOL_DISABLED+x} ]]; then
  echo -n "PoolTool is disabled."
  exit 0
fi

if [[ -z ${POOLTOOL_USER_ID+x} ]]; then
  echo -n 'Variable ${POOLTOOL_USER_ID+x} is empty!'
  exit 1
elif [[ -z ${JORM_NODE_STATS+x} ]]; then
  source /usr/local/lib/jcli-set-env-variables.sh
  if [[ ${JORM_NODE_TYPE} == 'relay' ]]; then
    echo -n "PoolTool reporting is not available for relay nodes."
    exit 1
  else
    JORM_NODE_STATS=$(jcli rest v0 node stats get --output-format json || exit 1)
  fi
fi

POOLTOOL_GENESIS_HASH=${GENESIS_HASH:0:7}
POOLTOOL_PLATFORM='2nd Layer Docker Health Check'
lastBlockHeight=$(echo ${JORM_NODE_STATS} | jq -r .lastBlockHeight)
jormVersion=$(echo ${JORM_NODE_STATS} | jq -r .version)
jormUptime=$(echo ${JORM_NODE_STATS} | jq -r .uptime)
lastBlockHash=$(echo ${JORM_NODE_STATS} | jq -r .lastBlockHash)
lastBlock=$(jcli rest v0 block ${lastBlockHash} get || exit 1)
lastPoolID=${lastBlock:168:64}
lastParent=${lastBlock:104:64}
lastSlot=$((0x${lastBlock:24:8}))
lastEpoch=$((0x${lastBlock:16:8}))

if [ "${lastBlockHeight}" != "" ]; then
  POOLTOOL_RESPONSE=$(curl -m 1 -s -G \
    --data-urlencode "platform=${POOLTOOL_PLATFORM}" \
    --data-urlencode "jormver=${jormVersion}" \
    "https://api.pooltool.io/v0/sharemytip?poolid=${JORM_POOL_ID}&userid=${POOLTOOL_USER_ID}&genesispref=${POOLTOOL_GENESIS_HASH}&mytip=${lastBlockHeight}&lasthash=${lastBlockHash}&lastpool=${lastPoolID}&lastparent=${lastParent}&lastslot=${lastSlot}&lastepoch=${lastEpoch}")
  POOLTOOL_STATUS=$(echo ${POOLTOOL_RESPONSE} | jq -r .success)
  if [[ ${POOLTOOL_STATUS} == 'true' ]]; then
    POOLTOOL_ERROR=$(echo ${POOLTOOL_RESPONSE} | jq -r .error)
    if [[ ${POOLTOOL_ERROR} == 'null' ]]; then
      POOLTOOL_CONFIDENCE=$(echo ${POOLTOOL_RESPONSE} | jq -r .confidence)
      if [[ ${POOLTOOL_CONFIDENCE} == 'true' ]]; then
        POOLTOOL_SAMPLES=$(echo ${POOLTOOL_RESPONSE} | jq -r .samples)
        POOLTOOL_MAXHEIGHT=$(echo ${POOLTOOL_RESPONSE} | jq -r .pooltoolmax)
      fi
    fi
  fi
fi
