#!/bin/bash --login
# shellcheck disable=SC1091
set -ex

die() { echo "error: $1"; exit "$2"; }

while getopts "h" opt; do
  case $opt in
    h)
      echo "Usage: $0 [setup|install|deploy|submit]"
      echo "  setup   - Setup spack environment"
      echo "  install - Install spack environment"
      echo "  deploy  - Deploy modules to shared environment"
      echo "  submit  - Submit results (placeholder for CDash/reporting)"
      ;;
    *)
      die "Invalid option: -$OPTARG" 1
      ;;
  esac
done
shift $((OPTIND-1))

readonly STEP=$1
[ -z "$STEP" ] && die "no argument given: $*" 2
shift

# Determine which spack environment to use based on job name
export SPACK_CONFIG_DAV_SDK_DIR=${PWD}/spack/configs
export SPACK_CONFIG_FACILITY_DIR="${SPACK_BUILD_DIR}/facility-config"

if [ -z "${SPACK_BUILD_DIR}" ]; then
  export SPACK_BUILD_DIR=${PWD}/build
fi

: "${NUM_CORES:=4}"

case ${STEP} in
  setup)
    echo "**********Setup Begin**********"
    git clone -c feature.manyFiles=true -b v1.1.0 https://github.com/spack/spack.git "${SPACK_BUILD_DIR}/spack"

    echo "**********Setup Begin**********"
    git clone https://github.com/E4S-Project/facility-external-spack-configs.git "${SPACK_CONFIG_FACILITY_DIR}"

    # Source spack environment
    . "${SPACK_BUILD_DIR}/spack/share/spack/setup-env.sh"

    # Activate the environment pointing to the config directory
    spack env activate --create --without-view --envfile "${PWD}/spack/configs/frontier/" davsdk

    if [ -n "${SPACK_BUILDCACHE_DIR}" ]; then
      spack mirror add --unsigned --autopush frontier "file://${SPACK_BUILDCACHE_DIR}"
    fi

    # Verify environment is active
    spack env status

    # Show configuration
    spack config blame

    # Concretize the environment
    spack concretize -f

    # Show what will be installed
    spack find

    # Download archives
    spack fetch --dependencies

    echo "**********Setup End**********"
    ;;

  install)
    echo "**********Install Begin**********"

    . "${SPACK_BUILD_DIR}/spack/share/spack/setup-env.sh"

    # Activate the environment pointing to the config directory
    spack env activate davsdk

    # Verify environment is active
    spack env status

    # Show configuration
    spack config blame

    # Install the environment with timing and parallel jobs
    spack -t install "-j$((NUM_CORES*2))" --show-log-on-error --no-check-signature --fail-fast | tee spack_log.out 2>&1

    # Show what was installed
    spack find -lv

    # Copy installed packages to lustre view if specified
    if [ -n "${SPACK_VIEW_DIR}" ]; then
      echo "Creating view at: ${SPACK_VIEW_DIR}"
      rm -rf "${SPACK_VIEW_DIR}"
      spack env view enable "${SPACK_VIEW_DIR}"
      spack env view regenerate
    fi

    echo "**********Install End**********"
    ;;

  deploy)
    echo "**********Deploy Begin**********"

    . "${SPACK_BUILD_DIR}/spack/share/spack/setup-env.sh"

    # Activate the environment
    spack env activate davsdk

    # Verify environment is active
    spack env status

    # Default deployment directory
    : "${SPACK_DEPLOY_DIR:=/lustre/orion/world-shared/ums032/frontier-deployed-env}"

    # Create deployment directory structure
    mkdir -p "${SPACK_DEPLOY_DIR}/modules"

    # Regenerate lmod modules with deployment path
    spack config add "modules:default:roots:lmod:${SPACK_DEPLOY_DIR}/modules"
    spack module lmod refresh --delete-tree --yes-to-all

    # Show generated modules
    echo "Generated modules:"
    find "${SPACK_DEPLOY_DIR}/modules" -type f -name "*.lua" | head -20

    # Show view location
    if [ -n "${SPACK_VIEW_DIR}" ]; then
      echo "Packages available at: ${SPACK_VIEW_DIR}"
    fi

    echo "**********Deploy End**********"
    ;;

  submit)
    echo "**********Submit Begin**********"
    # Placeholder for submission to CDash or other reporting systems
    echo "Submit step - currently a placeholder"
    echo "**********Submit End**********"
    ;;

  *)
    die "Unknown step: ${STEP}" 3
    ;;
esac

exit 0
