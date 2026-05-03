if("feature-a" IN_LIST FEATURES)
  file(INSTALL 
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/vcpkg-ci-eval"
    FILES "${CMAKE_CURRENT_LIST_DIR}/project/config.h"
  )
else()
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
endif()

file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "MIT\n")
