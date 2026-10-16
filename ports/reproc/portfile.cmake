vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DaanDeMeyer/reproc
    REF "${VERSION}"
    SHA512 d0f630ab1a9c43bbbda3ab4fbe7909966845be7b146ed5306ee1f864b6c29751e71a636d3414d3e8ff3f3a31054bbb69298b26f45a6c3b7b22191eed70e9d380
    HEAD_REF main
    PATCHES
        # https://github.com/daandemeyer/reproc/issues/124
        freebsd-stat.patch
        # https://github.com/daandemeyer/reproc/pull/123
        project-version.patch
        fallback-error.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DREPROC_DEVELOP=OFF
        -DREPROC++=ON
        -DREPROC_INSTALL_PKGCONFIG=OFF
        -DREPROC_INSTALL_CMAKECONFIGDIR=share
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(REPROC_SHARED 1)
else()
    set(REPROC_SHARED 0)
endif()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/reproc/export.h"
    "#ifdef REPROC_SHARED" "#if ${REPROC_SHARED}")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/reproc++/export.hpp"
    "#ifdef REPROCXX_SHARED" "#if ${REPROC_SHARED}")

foreach(TARGET reproc reproc++)
    vcpkg_cmake_config_fixup(
        PACKAGE_NAME ${TARGET}
    )
endforeach()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
