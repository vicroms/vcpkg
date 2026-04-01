vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO notnullnotvoid/msf_gif
    REF e280bc2189ed32b743c7f634cd21c0eb5def7046
    SHA512 891b88393ff00716bf90ff3227f79aa1c5115a366acea713d76cb3f8a83e42ed8b225d04c686be0ffd2e3e15c39580022ca9e915e2069819d767b96b19af1db1
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release)

file(INSTALL "${SOURCE_PATH}/msf_gif.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/msf_gif.h")
