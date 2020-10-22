#!/usr/bin/env bash
set -e

#source /usr/local/lib/cardano-node-set-env-variables.sh

function preExitHook () {
  exec "$@"
  echo 'Exiting...'
}

  preExitHook "$@"
  exit
