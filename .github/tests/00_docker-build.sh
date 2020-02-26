#!/bin/bash
set -e

if [ $1 == 'merge' ]; then
  branch=${2}
fi

echo "Running on branch: ${1}"

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
elif [ ${branch} == 'master' ]; then
  echo "Running on branch: ${branch}; building all images."
  for Dockerfile in $(find -name Dockerfile); do
    imageName=$(echo ${Dockerfile} | awk -F '/' '{ print $2 }')
    imageVersion=$(echo ${Dockerfile} | awk -F '/' '{ print $3 }')
    imageTag=${repositoryName}/${imageName}:${imageVersion}
    dockerfileDir=${imageName}/${imageVersion}
    fnBuildDockerImage
  done
elif [[ ${branch} =~ ^(add|update)-(jormungandr|cardano-node)-[0-9]+.*$ ]]; then
  imageName=$(echo ${branch} | awk -F '-' '{ print $2 }')
  imageVersion=$(echo ${branch} | awk -F '-' '{ print $3 }')
  imageTag=${repositoryName}/${imageName}:${imageVersion}
  dockerfileDir=${imageName}/${imageVersion}
  fnBuildDockerImage
else
  echo "Can't recognize argument!"
  exit 1
fi