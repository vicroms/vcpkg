vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vurtun/lib
    REF 5a3f3aba052e63ffae8eb0214c6bb8ffffedea3c
    SHA512 5010f3e8c049a670e65bf8a83ffcd27ef7382a2cfaeac1caf59760b4e43a3351e7d46dd1688ad0ae8e383e32875f74805b9fb7a09cf29d419b5634176afaa233
    HEAD_REF master
)

file(INSTALL
    "${SOURCE_PATH}/sinfl.h"
    "${SOURCE_PATH}/sdefl.h"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/sinfl.h")
set(VCPKG_BUILD_TYPE release)
