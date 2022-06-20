vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kdbusaddons
    REF v5.95.0
    SHA512 1e0cd6bbbbedfd7082a5aef066ed3e2681e39d838127eb15c15181d3a8df319495e6bb5ef48717ab78e06711623ee3bf23777b87c895b923ce06909d4dd45d52
    HEAD_REF master
    PATCHES
        fix-build.patch
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_WITH_QT6=ON
        -DEXCLUDE_DEPRECATED_BEFORE_AND_AT=5.94.0
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME KF5DBusAddons CONFIG_PATH lib/cmake/KF5DBusAddons)

vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
elseif(VCPKG_TARGET_IS_WINDOWS)
    # kquitapp5 is a non-dev tool allowing to quit an arbitrary, dbus-compatible app. No need to keep it.
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/kquitapp5${VCPKG_HOST_EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/debug/bin/kquitapp5${VCPKG_HOST_EXECUTABLE_SUFFIX}")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSES/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")
