cmake_minimum_required(VERSION 3.15)

project(dav-sdk
    LANGUAGES NONE
    DESCRIPTION "spack configs for the dav sdk"
    HOMEPAGE_URL dav-sdk.github.io)

install(FILES spack/configs/packages.yaml DESTINATION spack/configs/davsdk)
install(DIRECTORY spack/configs/template DESTINATION spack/environments/davsdk)
install(DIRECTORY spack/configs/frontier DESTINATION spack/environments/davsdk)
