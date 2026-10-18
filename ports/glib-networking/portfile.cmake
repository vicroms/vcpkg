if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

string(REGEX MATCH [[^[0-9][0-9]*\.[1-9][0-9]*]] VERSION_MAJOR_MINOR "${VERSION}")
vcpkg_download_distfile(ARCHIVE
    URLS
        "https://download.gnome.org/sources/${PORT}/${VERSION_MAJOR_MINOR}/${PORT}-${VERSION}.tar.xz"
        "https://www.mirrorservice.org/sites/ftp.gnome.org/pub/GNOME/sources/${PORT}/${VERSION_MAJOR_MINOR}/${PORT}-${VERSION}.tar.xz"
    FILENAME "GNOME-${PORT}-${VERSION}.tar.xz"
    SHA512 a94c5d0e9775cf7d6bf1cfd6132ff2bb90ec53915bf169d59548fe6a914007837a9a139d2aee8c562006c53e78ddf74b0279c542c10c95cd9ae8929c4af4e46e
)

vcpkg_extract_source_archive(SOURCE_PATH ARCHIVE "${ARCHIVE}")

vcpkg_list(SET FEATURE_OPTIONS)
if (gnutls IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -Dgnutls=enabled)
else()
    list(APPEND FEATURE_OPTIONS -Dgnutls=disabled)
endif()

if (openssl IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -Dopenssl=enabled)
else()
    list(APPEND FEATURE_OPTIONS -Dopenssl=disabled)
endif()

if (libproxy IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -Dlibproxy=enabled)
else()
    list(APPEND FEATURE_OPTIONS -Dlibproxy=disabled)
endif()

if (environment-proxy IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -Denvironment_proxy=enabled)
else()
    list(APPEND FEATURE_OPTIONS -Denvironment_proxy=disabled)
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -Dgnome_proxy=disabled
    ADDITIONAL_BINARIES
        "gio-querymodules = '${CURRENT_HOST_INSTALLED_DIR}/tools/glib/gio-querymodules${CMAKE_EXECUTABLE_SUFFIX}'"
)

vcpkg_install_meson()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    foreach(config IN ITEMS "" "/debug")
        file(GLOB MODULE_ARCHIVES "${CURRENT_PACKAGES_DIR}${config}/lib/gio/modules/*.a")
        foreach(archive IN LISTS MODULE_ARCHIVES)
            cmake_path(GET archive FILENAME name)
            file(RENAME "${archive}" "${CURRENT_PACKAGES_DIR}${config}/lib/${name}")
        endforeach()
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}${config}/lib/pkgconfig")
        file(GLOB MODULE_PKGCONFIG_FILES "${CURRENT_PACKAGES_DIR}${config}/lib/gio/modules/pkgconfig/*.pc")
        foreach(pc IN LISTS MODULE_PKGCONFIG_FILES)
            vcpkg_replace_string("${pc}" "/lib/gio/modules" "/lib")
            cmake_path(GET pc FILENAME name)
            file(RENAME "${pc}" "${CURRENT_PACKAGES_DIR}${config}/lib/pkgconfig/${name}")
        endforeach()
        file(REMOVE_RECURSE
            "${CURRENT_PACKAGES_DIR}${config}/lib/gio"
            "${CURRENT_PACKAGES_DIR}${config}/lib/systemd"
        )
    endforeach()
    vcpkg_fixup_pkgconfig()
else()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/gio/modules/pkgconfig")
    file(GLOB MODULE_FILES "${CURRENT_PACKAGES_DIR}/lib/gio/modules/*")
    file(COPY ${MODULE_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/plugins/${PORT}")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/gio/modules/pkgconfig")
    file(GLOB MODULE_DEBUG_FILES "${CURRENT_PACKAGES_DIR}/debug/lib/gio/modules/*")
    file(COPY ${MODULE_DEBUG_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/plugins/${PORT}")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib")
endif()

if(libproxy IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES glib-pacrunner SEARCH_DIR "${CURRENT_PACKAGES_DIR}/libexec")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/libexec" "${CURRENT_PACKAGES_DIR}/debug/libexec")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/dbus-1/services/org.gtk.GLib.PACRunner.service" "${CURRENT_PACKAGES_DIR}/libexec/glib-pacrunner" "${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}/glib-pacrunner")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    configure_file("${CMAKE_CURRENT_LIST_DIR}/usage-static" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
else()
    file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
endif()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
