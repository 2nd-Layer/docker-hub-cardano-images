#!/bin/bash
set -e

echo "Running on branch: ${1}"

if [ -z ${1+x} ]; then
  echo "No argument provided!"
  exit 1
elif [ ${1} == 'master' ]; then
  echo "Running on branch: ${1}; building all images."
  for Dockerfile in $(find -name Dockerfile); do
    imageName=$(echo ${Dockerfile} | awk -F '/' '{ print $2 }')
    imageVersion=$(echo ${Dockerfile} | awk -F '/' '{ print $3 }')
    imageTag=${repositoryName}/${imageName}:${imageVersion}
    dockerfileDir=${imageName}/${imageVersion}
    fnBuildDockerImage
  done
elif [[ ${1} =~ ^(add|update)-(jormungandr|cardano-node)-[0-9]+.*$ ]]; then
  imageName=$(echo ${1} | awk -F '-' '{ print $2 }')
  imageVersion=$(echo ${1} | awk -F '-' '{ print $3 }')
  imageTag=${repositoryName}/${imageName}:${imageVersion}
  dockerfileDir=${imageName}/${imageVersion}
  fnBuildDockerImage
else
  echo "Can't recognize argument!"
  exit 1
fi

function fnBuildDockerImage {
  imageTag=${repositoryName}/${imageName}:${imageVersion}
  dockerfileDir=${imageName}/${imageVersion}
  echo "Building Dockerfile for ${imageTag}"
  pushd ${dockerfileDir}
    docker build -t ${imageTag} ./
  popd
}