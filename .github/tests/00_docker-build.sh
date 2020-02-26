#!/bin/bash
set -e

if [ $1 == 'merge' ]; then
  branchName=${2}
else
  branchName=${1}
fi

echo "Running on branch: ${branchName}"

function fnBuildDockerImage {
  imageTag=${repositoryName}/${imageName}:${imageVersion}
  dockerfileDir=${imageName}/${imageVersion}
  echo "Building Dockerfile for ${imageTag}"
  pushd ${dockerfileDir}
    docker build -t ${imageTag} ./
  popd
}

repositoryName='2ndlayer'

if [ -z ${1+x} ]; then
  echo "Not enough arguments provided!"
  exit 1
elif [ ${branchName} == 'master' ]; then
  echo "Running on branch: ${branchName}; building all images."
  for Dockerfile in $(find -name Dockerfile); do
    imageName=$(echo ${Dockerfile} | awk -F '/' '{ print $2 }')
    imageVersion=$(echo ${Dockerfile} | awk -F '/' '{ print $3 }')
    imageTag=${repositoryName}/${imageName}:${imageVersion}
    dockerfileDir=${imageName}/${imageVersion}
    fnBuildDockerImage
  done
elif [[ ${branchName} =~ ^(add|update)-(jormungandr|cardano-node)-[0-9]+.*$ ]]; then
  if [[ ${branchName} =~ ^.*-cardano-node-.* ]]; then
    imageName='cardano-node'
    imageVersion=$(echo ${branchName} | awk -F '-' '{ print $4 }')
  else
    imageName=$(echo ${branchName} | awk -F '-' '{ print $2 }')
    imageVersion=$(echo ${branchName} | awk -F '-' '{ print $3 }')
  fi
  imageTag=${repositoryName}/${imageName}:${imageVersion}
  dockerfileDir=${imageName}/${imageVersion}
  fnBuildDockerImage
else
  echo "Can't recognize branchName: ${branchName}!"
  exit 0
fi