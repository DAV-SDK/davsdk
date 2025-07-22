#!/bin/bash
set -e

export DEPLOY_PREFIX="${PREFIX:-/sw/frontier/ums/ums032/spack}"
export SDK_DEPLOY_VERSION=$(date +%y.%m.%d)

version_info()
{
  dir=$1

  pushd $dir > /dev/null

  if [[ $(git status &> /dev/null) ]]; then
    if [[ $(git describe &> /dev/null) ]]; then
      git describe
    else
      git rev-parse HEAD
    fi
  else
    echo "$(realpath $dir)"
  fi

  popd > /dev/null
}

# Configure working directory for this deployment
mkdir -p ${DEPLOY_PREFIX}/${SDK_DEPLOY_VERSION}
cd ${DEPLOY_PREFIX}/${SDK_DEPLOY_VERSION}

echo "$PWD"
# Clear the deployment manifest
log="${DEPLOY_PREFIX}/${SDK_DEPLOY_VERSION}/manifest.txt"
echo -n > $log

echo "Initializing Facility configs..."
if [ -z $FACILITY_CONFIG_ROOT ]; then
  local facility_config_tag=${FACILITY_CONFIG_TAG:-master}
  git clone --depth 1 --branch ${facility_config_tag} git@github.com:E4S-Project/facility-external-spack-configs.git
  FACILITY_CONFIG_ROOT=$PWD/facility-external-spack-configs
fi
export FACILITY_CONFIG_ROOT
echo "facility-external-spack-configs" >> $log
version_info "$FACILITY_CONFIG_ROOT" >> "$log"

echo "Initializing DAV SDK configs..."
if [ -z $DAV_SDK_CONFIG_ROOT ]; then
  local dav_sdk_config_tag=${DAV_SDK_CONFIG_TAG:-main}
  git clone --depth 1 --branch ${dav_sdk_config_tag} git@github.com:DAV-SDK/davsdk.git
  DAV_SDK_CONFIG_ROOT=$PWD/davsdk
fi
export DAV_SDK_CONFIG_ROOT
echo "dav-configs" >> $log
version_info "$DAV_SDK_CONFIG_ROOT" >> "$log"

echo "Initializing Spack..."
# Configure Spack for deployment
if [ -z $SPACK_ROOT ]; then
  local spack_tag=${SPACK_TAG:-develop}
  git cloen --depth 1 --branch ${spack_tag} git@github.com:spack/spack.git
  . ./spack/share/spack/setup-env.sh
else
  # Minimally attempt to re-source Spack
  . ${SPACK_ROOT}/share/spack/setup-env.sh
fi
spack debug report >>  "$log"

echo $log
cat $log
read

echo "Activating environment at ... ${DAV_SDK_CONFIG_ROOT}/spack/configs/frontier"
spack env activate ${DAV_SDK_CONFIG_ROOT}/spack/configs/frontier
spack env status

spack config blame &> ${DEPLOY_PREFIX}/${SDK_DEPLOY_VERSION}/configs.blame.txt
echo "Verify config..."
read

echo "Concretizing..."
spack concretize -f |& tee ${DEPLOY_PREFIX}/${SDK_DEPLOY_VERSION}/concrete.txt
echo "Verify Concretization..."
read

spack -t install -j 8 |& tee ${DEPLOY_PREFIX}/${SDK_DEPLOY_VERSION}/install.txt
  
spack module lmod refresh --delete-tree -y
