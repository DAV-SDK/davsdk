#!/bin/bash
set -e

DEPLOY_PREFIX="${PREFIX:-/sw/frontier/ums/ums032/spack}"
SDK_DEPLOY_VERSION=$(date +%y.%m.%d)

function append_version_info()
{
  dir=$1
  out=$2

  pushd $dir

  if [ $(git status) ]; then
    if [ $(git describe) ]; then
      git describe >> $out
    else
      git rev-parse HEAD >> $out
    fi
  else
    echo "$(realpath $dir)" >> $out
  fi

  popd
}

# Configure working directory for this deployment
mkdir -p ${DEPLOY_PREFIX}/${SDK_DEPLOY_VERSION}

# Clear the deployment manifest
log="manifest.txt"
echo -n > $log

# Collect the configuration files to use
if [ -z $FACILITY_CONFIG_ROOT ]; then
  local facility_config_tag=${FACILITY_CONFIG_TAG:-master}
  git clone --depth 1 --branch ${facility_config_tag} git@github.com:E4S-Project/facility-external-spack-configs.git
  FACILITY_CONFIG_ROOT=$PWD/facility-external-spack-configs
if
echo "facility-external-spack-configs" >> $log
append_version_info "$FACILITY_CONFIG_ROOT" "$log"

if [ -z $DAV_SDK_CONFIG_ROOT ]; then
  local dav_sdk_config_tag=${DAV_SDK_CONFIG_TAG:-main}
  git clone --depth 1 --branch ${dav_sdk_config_tag} git@github.com:DAV-SDK/davsdk.git
  DAV_SDK_CONFIG_ROOT=$PWD/davsdk
fi
echo "dav-configs" >> $log
append_version_info "$DAV_SDK_CONFIG_ROOT" "$log"

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

spack env activate ${DAV_SDK_CONFIG_ROOT}/spack/configs/frontier

spack config blame
echo "Verify config..."
read

spack concretize -f
echo "Verify Concretization..."
read

spack install -j 8
