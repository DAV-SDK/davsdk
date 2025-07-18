cmake_minimum_required(VERSION 3.15)

project(dav-sdk
    LANGUAGES NONE
    DESCRIPTION "spack configs for the dav sdk"
    HOMEPAGE_URL dav-sdk.github.io)

set(all_facilities frontier)

set(FACILITY "all" CACHE STRING "The facility configs to install")
set_property(CACHE FACILITY PROPERTY STRINGS
        "all" ${all_facilities})
list(TRANSFORM all_facilities PREPEND "spack/configs/")
install(DIRECTORY "$<IF:$<STREQUAL:${FACILITY},all>,${all_facilities},spack/configs/${FACILITY}>"
        DESTINATION spack/environments/davsdk)

install(FILES spack/configs/packages.yaml DESTINATION spack/configs/davsdk)
install(DIRECTORY spack/configs/template DESTINATION spack/environments/davsdk)
