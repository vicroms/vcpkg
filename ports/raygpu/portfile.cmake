vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO manuel5975p/raygpu
    REF dca0b66adef381ba609ca2a10ed9bc059a00e5b4
    SHA512 af567f20c5beb1b2ca64ade5711534c97eb8edc9a2e2cdd7360afdc1697dc3fbd349617cfc1587571e77c9eab9e544146d9125ba51362ff3744e97432117ffc4
    HEAD_REF master
    PATCHES
        patches/001-use-vcpkg-wgvk.patch
        patches/002-disable-examples.patch
        patches/003-fix-install-targets.patch
        patches/004-devendor-all.patch
)

# Shared library builds require proper DLL export annotations; use static for now
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# Remove bundled source trees now replaced by vcpkg dependencies
# NOTE: amalgamation/glslang is NOT removed — raygpu uses private glslang headers
# NOTE: tinyobj_loader_c.h is NOT removed — vcpkg version has an incompatible API
file(REMOVE_RECURSE "${SOURCE_PATH}/amalgamation/glfw-3.4")
file(REMOVE_RECURSE "${SOURCE_PATH}/amalgamation/SPIRV-Reflect")
file(REMOVE_RECURSE "${SOURCE_PATH}/amalgamation/vulkan_headers")
foreach(_hdr
    cgltf.h msf_gif.h par_shapes.h sinfl.h sdefl.h
    stb_image.h stb_image_write.h stb_rect_pack.h stb_truetype.h)
    file(REMOVE "${SOURCE_PATH}/include/external/${_hdr}")
endforeach()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DRAYGPU_ENABLE_INSTALL=ON
        -DRAYGPU_BUILD_TESTS=OFF
        -DRAYGPU_BUILD_EXAMPLES=OFF
        -DRAYGPU_GENERATE_PYTHON_BINDINGS=OFF
        -DRAYGPU_BUILD_SHARED_LIBRARY=OFF
        -DBUILD_TESTING=OFF
        # Use the Vulkan backend (default for desktop targets) via the wgvk vcpkg port
        -DSUPPORT_VULKAN_BACKEND=ON
        -DSUPPORT_WGPU_BACKEND=OFF
        # Enable GLSL shader compilation via vcpkg glslang
        -DSUPPORT_GLSL_PARSER=ON
        -DSUPPORT_WGSL_PARSER=OFF
        # Enable GLFW windowing via vcpkg glfw3
        -DSUPPORT_GLFW=ON
        -DSUPPORT_SDL3=OFF
        -DSUPPORT_RGFW=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/raygpu)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Remove files not needed in the installed package
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/external")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")

# config.h is part of raygpu's public API
set(VCPKG_POLICY_ALLOW_RESTRICTED_HEADERS enabled)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
