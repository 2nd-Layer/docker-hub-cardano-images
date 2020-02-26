#!/bin/bash
set -e

echo "Running on branch: ${1}"

if [ -z ${1+x} ] || [ ${1} == 'master' ]; then
  for Dockerfile in $(find -name Dockerfile); do
    imageName=$(echo ${Dockerfile} | awk -F '/' '{ print $2 }')
    imageVersion=$(echo ${Dockerfile} | awk -F '/' '{ print $3 }')
    imageTag=${repositoryName}/${imageName}:${imageVersion}
    dockerfileDir=${imageName}/${imageVersion}
    fnBuildDockerImage
  done
else
  imageName=$(echo ${1} | awk -F '-' '{ print $2 }')
  imageVersion=$(echo ${1} | awk -F '-' '{ print $3 }')
  imageTag=${repositoryName}/${imageName}:${imageVersion}
  dockerfileDir=${imageName}/${imageVersion}
fi

function fnBuildDockerImage {
  imageTag=${repositoryName}/${imageName}:${imageVersion}
  dockerfileDir=${imageName}/${imageVersion}
  echo "Building Dockerfile for ${imageTag}"
  pushd ${dockerfileDir}
    docker build -t ${imageTag} ./
  popd
}