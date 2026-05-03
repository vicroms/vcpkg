vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        feature-a WITH_FEATURE_A
        feature-b WITH_FEATURE_B
        feature-c WITH_FEATURE_C
)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS ${FEATURE_OPTIONS}
)

if("feature-a" IN_LIST FEATURES)
    vcpkg_cmake_build()
endif()

if("feature-b" IN_LIST FEATURES OR "feature-c" IN_LIST FEATURES)
    vcpkg_cmake_install()
endif()

if("feature-b" IN_LIST FEATURES)
    vcpkg_install_copyright(FILE_LIST "${CURRENT_PORT_DIR}/copyright")
elseif("feature-c" IN_LIST FEATURES)
    file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "MIT\n")
endif()

if(NOT "feature-a" IN_LIST FEATURES AND NOT "feature-b" IN_LIST FEATURES AND NOT "feature-c" IN_LIST FEATURES)
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "MIT\n")
endif()
