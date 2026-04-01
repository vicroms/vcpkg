vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO manuel5975p/WGVK
    REF d9c6dad5af37261b32c6045a061f9a58ee45c13a
    SHA512 f619f9cb08e75fd81c9a458b1409c6d11ed7b7a29650527dd9110a9f106445d0cef5ca7f22eea0fea1ec2445c667d154b70bc1dbac2dd052643b6ba1ba407cc4
    HEAD_REF master
    PATCHES
        patches/001-add-cmake-config.patch
        patches/002-devendor-volk.patch
)

# Write the cmake config template (referenced by patch 001)
file(MAKE_DIRECTORY "${SOURCE_PATH}/cmake")
file(WRITE "${SOURCE_PATH}/cmake/wgvkConfig.cmake.in" [[@PACKAGE_INIT@
include(CMakeFindDependencyMacro)
find_dependency(volk CONFIG)
include("${CMAKE_CURRENT_LIST_DIR}/wgvkTargets.cmake")
]])

# Replace the bundled volk.h with a compatibility shim so consumers that
# include <external/volk.h> (e.g. raygpu) continue to work without changes.
# The actual volk implementation is now provided by the volk vcpkg port.
file(WRITE "${SOURCE_PATH}/include/external/volk.h"
    "/* Compatibility shim: volk is now provided by the volk vcpkg dependency. */\n"
    "#include <volk.h>\n"
)

# Remove the vendored volk implementation file (no longer compiled inline)
file(REMOVE "${SOURCE_PATH}/include/external/volk.c")

# Remove the bundled Vulkan and vk_video headers; the vcpkg volk port brings
# vulkan-headers as a transitive dependency, providing these from a single source.
file(REMOVE_RECURSE "${SOURCE_PATH}/include/vulkan")
file(REMOVE_RECURSE "${SOURCE_PATH}/include/vk_video")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DWGVK_BUILD_EXAMPLES=OFF
        -DWGVK_BUILD_GLSL_SUPPORT=OFF
        -DWGVK_WGSL_SUPPORT=OFF
        -DWGVK_USE_VMA=OFF
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/wgvk)

# Install the external/ headers (volk, vk_mem_alloc, etc.) needed by consumers
# that use WGVK's Vulkan backend (e.g., raygpu includes <external/volk.h>)
file(INSTALL "${SOURCE_PATH}/include/external"
     DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Remove README installed by upstream
file(REMOVE "${CURRENT_PACKAGES_DIR}/README.txt")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/README.txt")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
