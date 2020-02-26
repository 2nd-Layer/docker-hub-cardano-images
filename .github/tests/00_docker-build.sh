#!/bin/bash
set -e

echo ${1}

repositoryName="2ndlayer"

for Dockerfile in $(find -name Dockerfile); do
  imageName=$(echo ${Dockerfile} | awk -F '/' '{ print $2 }')
  imageVersion=$(echo ${Dockerfile} | awk -F '/' '{ print $3 }')
  imageTag=${repositoryName}/${imageName}:${imageVersion}
  dockerfileDir=${imageName}/${imageVersion}
  echo "Building Dockerfile for ${imageTag}"
  pushd ${dockerfileDir}
  docker build -t ${imageTag} ./
  popd
done
