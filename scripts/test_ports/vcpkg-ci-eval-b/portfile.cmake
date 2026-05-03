vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        feature-a WITH_FEATURE_A
)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS ${FEATURE_OPTIONS}
)

if("feature-a" IN_LIST FEATURES)
    vcpkg_cmake_install()
    file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "MIT\n")
else()
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "MIT\n")
endif()
