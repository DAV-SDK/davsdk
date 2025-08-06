# Configuring Frontier

The configuration for Frontier requires two variables be set.

The first is for the DAV SDK configurations root (`DAV_SDK_ROOT`), which is
the root of the configs in the DAV SDK repository.

ie.

```console
$ # To use the files directly from github
$ export SPACK_CONFIG_DAV_SDK_DIR=https://raw.githubusercontent.com/dav-sdk/davsdk/refs/heads/main/spack/configs
$
$ # Or
$
$ # To use a local clone of the configs
$ export SPACK_CONFIG_DAV_SDK_DIR=$HOME/.spack/dav-sdk/spack/configs
```

The second variable to set is the Frontier configs path. These configs are maintained in cunjunction with
the E4S team. ([Spack Facility Configs](https://github.com/E4S-Project/facility-external-spack-configs))

ie.

```console
$ # To use the files directly from github
$ export SPACK_CONFIG_FACILITY_DIR=https://raw.githubusercontent.com/E4S-Project/facility-external-spack-configs/refs/heads/main
$
$ # Or
$
$ # To use a local clone of the configs
$ export SPACK_CONFIG_FACILITY_DIR=$HOME/.spack/facility-configs/

```
