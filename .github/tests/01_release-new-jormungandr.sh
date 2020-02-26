#!/bin/bash
set -e

which jq >> /dev/null 2>&1 || echo "jq binary is missing!"

GH_JSON=$(curl --proto '=https' --tlsv1.2 -sSf "https://api.github.com/repos/input-output-hk/jormungandr/releases/latest")
if [ $(echo ${GH_JSON} | jq -r .prerelease) == false ]; then
  jormVersionTag=$(echo ${GH_JSON} | jq -r .tag_name)
  echo "Discovered Jormungandr ${jormVersionTag}"
  jormVersion=${jormVersionTag:1}
fi
echo "Looking for Jormungandr ${jormVersion} directory..."
if [ -d jormungandr/${jormVersion} ]; then
  echo "Jormungandr ${jormVersion} Docker image is already prepared!"
  export DOCKER_CLI_EXPERIMENTAL=enabled
  if $(docker manifest inspect 2ndlayer/centos-cardano-jormungandr:${jormVersion} >> /dev/null 2>&1); then
    echo "Jormungandr ${jormVersion} Docker image is already released on Docker Hub!"
  else
    echo "Jormungandr ${jormVersion} Docker image is not yet on Docker Hub!"
    exit 1
  fi
  exit 0
else
  echo "Jormungandr ${jormVersion} Docker image was not yet prepared."
  pushd jormungandr
  git checkout -b add-jormungandr-${jormVersion}
  lastJormImageVersion=$(ls -vFd * |  grep '\/$' | tail -n 1 | sed -e 's/\///')
  echo "Last prepared version is ${lastJormImageVersion}."
  cp -R ${lastJormImageVersion} ${jormVersion}
  pushd ${jormVersion}
  sed -e \
    "s/JORMUNGANDR_VERSION=\"v${lastJormImageVersion}\"/JORMUNGANDR_VERSION=\"v${jormVersion}\"/" \
    -i Dockerfile
  popd
  git add ${jormVersion}
  popd
  git -c user.name='Mark Stopka' \
      -c user.email='mark.stopka@perlur.cloud' \
      commit -m "Add Jormungandr ${jormVersion}"
  git push origin add-jormungandr-${jormVersion}
fi
