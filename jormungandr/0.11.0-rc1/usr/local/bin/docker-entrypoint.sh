#!/usr/bin/env bash
set -e

source /usr/local/lib/jcli-set-env-variables.sh

function preExitHook () {
  exec "$@"
  echo 'Exiting...'
}

function testStorage () {
  if [[ -d ${JORM_DB_DIR} ]]; then
    if [[ -f ${JORM_DB_DIR}blocks.sqlite ]]; then
      if [[ ! -r ${JORM_DB_DIR}blocks.sqlite ]]; then
        echo "ERROR: Database storage file ${JORM_DB_DIR}/blocks.sqlite is not readable!"
        echo "DEBUG: Expected file ownership $(id)"
        preExitHook "$@"
        exit
        if [[ ! -w ${JORM_DB_DIR}blocks.sqlite ]]; then
          echo "ERROR: Database storage file ${JORM_DB_DIR}/blocks.sqlite is not writeable!"
          echo "DEBUG: Expected file ownership $(id)"
          preExitHook "$@"
          exit
        fi
      fi
    fi
    else
      echo "ERROR: Jormungandr database storage directory ${JORM_DB_DIR} does not exist!"
  fi
}

function setPublicIPvariable () {
  case $1 in
    IPv4)
      if PUBLIC_IPV4=$(curl --proto '=https' --tlsv1.2 -sSf --ipv4 https://ifconfig.co/); then
        export PUBLIC_IPV4=${PUBLIC_IPV4}
      else
        echo "Autodetect faied!"
      fi
    ;;
    IPv6)
      if PUBLIC_IPV6=$(curl --proto '=https' --tlsv1.2 -sSf --ipv6 https://ifconfig.co/); then
        export PUBLIC_IPV6=${PUBLIC_IPV6}
      else
        echo "Autodetect faied!"
      fi
    ;;
    all)
      setPublicIPvariable IPv4
      setPublicIPvariable IPv6
  esac
}

if [[ -z ${PUBLIC_IPV4} ]]; then
  counter=1
  while [[ -z ${PUBLIC_IPV4} ]] && [[ $counter -lt 11 ]]; do
    echo 'Public IPv4 IP address not set! Trying autodetect... (' $counter '/10)'
    setPublicIPvariable "IPv4"
    let "counter++"
    if [[ -z ${PUBLIC_IPV4} ]] && [[ $counter -eq 10 ]]; then
      echo "Failed to obtain public IPv4 address!"
      preExitHook "$@"
      exit
    fi
  done
fi

if [[ -z ${PUBLIC_IPV6} ]]; then
  counter=1
  while [[ -z ${PUBLIC_IPV6} ]] && [[ $counter -lt 11 ]]; do
    echo 'Public IPv6 IP address not set! Trying autodetect... (' $counter '/10)'
    setPublicIPvariable "IPv6"
    let "counter++"
    if [[ -z ${PUBLIC_IPV6} ]] && [[ $counter -eq 10 ]]; then
      echo "Failed to obtain public IPv6 address; continuing..."
    fi
  done
fi

if [[ -z ${PUBLIC_IPV4} ]]; then
  PUBLIC_IPV4="NOT SET; unable to be a slot leader!"
fi

if [[ -z ${PUBLIC_IPV6} ]]; then
  PUBLIC_IPV6="NOT SET."
fi

echo 'Public IPv4 address is:' ${PUBLIC_IPV4}
echo 'Public IPv6 address is:' ${PUBLIC_IPV6}

if [[ ! -f ${GENESIS_HASH_FILE} ]]; then
  echo 'Genesis hash file does not exist! Jormungandr can NOT start!!!'
  preExitHook "$@"
  exit
else
  GENESIS_HASH=$(cat ${GENESIS_HASH_FILE})
  echo "Genesis hash set to ${GENESIS_HASH}!"
fi

if [[ ! -f ${JORM_CONF_FILE} ]]; then
  echo 'Jormungandr node config file does not exists! Jormungandr can NOT start!!!'
  preExitHook "$@"
  exit
else
  testStorage
  if [[ ! -f ${JORM_SECRET_FILE} ]]; then
    echo "Jormungandr node secret file not found! Jormungandr will start in a passive mode!"
    jormungandr \
      --genesis-block-hash ${GENESIS_HASH} \
      --config ${JORM_CONF_FILE}
  else
    echo 'Jormungand node secret file found! Jormungandr will start in a slot leader mode!'
    jormungandr \
      --genesis-block-hash ${GENESIS_HASH} \
      --config ${JORM_CONF_FILE} \
      --secret ${JORM_SECRET_FILE}
  fi
fi

exec "$@"
