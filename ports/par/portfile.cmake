vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO prideout/par
    REF b3571fdf83518d921af3b69d13ea0cb8749147aa
    SHA512 31626e5ab720ad2dbd0e6e7e31072b6d2ebaba9a6694b2d0e35903a4c10dfd3a3b027ed662c77fa9d4275fe352020eb17caec8560480c3c31d5f0849cea96fd7
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release)

file(INSTALL "${SOURCE_PATH}/par_shapes.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/par_shapes.h")
