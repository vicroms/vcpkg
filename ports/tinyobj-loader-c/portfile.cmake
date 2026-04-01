vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO syoyo/tinyobjloader-c
    REF 0f8ea84a0da616790b476912e1ccc641f36b463e
    SHA512 26a3206c83a820696d0fd65d21e056df8db1115a209f3ce735d9c36c136a3f1deb373c464ed3e1b4e42a251d600befda5b0e325c62572002f26e414c9d5cc4bc
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release)

file(INSTALL "${SOURCE_PATH}/tinyobj_loader_c.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/tinyobj_loader_c.h")
