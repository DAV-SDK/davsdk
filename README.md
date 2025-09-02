# DAV SDK
Available as either a Spack meta-package or spack environment configuration, which builds a set of DAV SDK member
packages together in a way that enables optimal features for target environments as well as interoperable features
provided by other packages within the DAV SDK.

## Using the Meta Package

The primary motivation for maintaining the meta package is to provide a simplified workflow for installing DAV
packages from a single command and minimal system configuration. This can be very useful on a desktop or for quickly
testing the DAV packages.

The meta package for the Data and Vis SDK is available in the built-in package repository in Spack. Each of the
packages in the SDK are expressed as variants which are disabled by default. This allows building only the
components of the SDK that are desired.

An example of installing the `dav-sdk` with Adios2, Ascent, and ZFP here.

```console
spack install dav-sdk +adios2 +ascent +zfp
```

## Using the Spack Environment

The DAV SDK Spack environment(s) available in `spack/configs` target a specific HPC facilities. All of the environments are
composed of included common components from the [facility configurations](https://github.com/E4S-Project/facility-external-spack-configs)
and the common SDK configs in `spack/configs`.

It is possible to use the common configs to create a an environment using the DAV SDK package configs. Here is an example configuration
template.

First you need to install Spack and the DAV SDK configs.

```console
# See platform installation instructions at https://spack.readthedocs.io/en/latest/getting_started.html#installation
git clone -c feature.manyFiles=true https://github.com/spack/spack.git

# Install Linux for bash/zsh/sh
. spack/share/spack/setup-env.sh

# Clone the DAV SDK Configs next to Spack
git clone https://github.com/dav-sdk/davsdk.git
```

Then create an enviornment which includes the common DAV SDK configs and lists the the the DAV SDK member packages as specs.
One may also list additional user defined specs here and they will be configured with the DAV SDK packages as well.

This configuration is located at `spack/configs/template/spack.yaml` and can be used as a simple starting point for creating
DAV SDK environments.

```yaml
spack:
  concretizer:
    unify: true

  include:
  # Include the DAV SDK package configs
  # These specify the constraints defined by the DAV SDK
  - $spack/../davsdk/spack/configs/packages.yaml

  specs:
  # I/O
  - adios2
  - parallel-netcdf
  - hdf5
  - hdf5-vol-async
  - hdf5-vol-cache
  - hdf5-vol-log

  # Compression
  - zfp

  # Visualization
  - ascent
  - paraview
  - vtk-m
```

**Note**: In this example `unify: true` is specified. The configurations for the DAV SDK are designed to be compatible in a
fully unified environment with all of the member packages listed. This is not, however, a requirement of the SDK configs.


## Using Spack Manager

The DAV SDK configs can be installed via Spack with `spack install spack-configs-dav-sdk`, which will also install the facility configs.
These can be used to make a [Spack Manager](https://sandialabs.github.io/spack-manager/index.html) project for the DAV SDK.

Let `davsdk-project` be the Spack Manager project directory. Link the necessary configs into the project.

```console
mkdir -p davsdk-prokect/configs/base

# Link base DAV SDK config
ln -s $SPACK_CONFIG_DAV_SDK_DIR/packages.yaml davsdk-project/configs/base/packages.yaml

# Link specific facility configs
ln -s $SPACK_CONFIG_FACILITY_DIR/<facility> davsdk-project/configs/<facility>
```

The project can then be added to Spack Manager and used to create a Spack environment.

```console
spack manager add davsdk-project
spack manager create-env -p davsdk-project -d davsdk-env -m <facility>
```
