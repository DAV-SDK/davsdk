# Configuring Frontier

The configuration for Frontier requires two variables be set.

The first is for the DAV SDK configurations root (`DAV_SDK_ROOT`), which is
the root of the configs in the DAV SDK repository.

ie.

```console
$ # To use the files directly from github
$ export DAV_SDK_ROOT=https://raw.githubusercontent.com/dav-sdk/davsdk/refs/heads/main
$
$ # Or
$
$ # To use a local clone of the configs
$ export DAV_SDK_ROOT=$HOME/.spack/dav-sdk/
```

The second variable to set is the Frontier configs path. These configs are maintained in cunjunction with
the E4S team. ([Spack Facility Configs](https://github.com/E4S-Project/facility-external-spack-configs))

ie.

```console
$ # To use the files directly from github
$ export FACILITY_CONFIG_ROOT=https://raw.githubusercontent.com/E4S-Project/facility-external-spack-configs/refs/heads/main
$
$ # Or
$
$ # To use a local clone of the configs
$ export FACILITY_CONFIG_ROOT=$HOME/.spack/facility-configs/

```
