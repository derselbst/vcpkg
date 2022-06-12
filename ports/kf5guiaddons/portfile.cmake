vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kguiaddons
    REF v5.95.0
    SHA512 de014e148248fcb5620138576c5290cba66f4ec5c13a41bbc8e9b97218bae763bd3909083f9fd7b1b03acb532789c28ad91be29907ecaa28bc07395b33200dc1
    HEAD_REF master
    PATCHES
        fix_cmake.patch # https://github.com/microsoft/vcpkg/issues/17607#issuecomment-831518812
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        wayland   WITH_WAYLAND
)

if("wayland" IN_LIST FEATURES AND NOT VCPKG_TARGET_IS_LINUX)
    message(FATAL_ERROR "Feature wayland is only supported on Linux.")
endif()

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_WITH_QT6=ON
        -DEXCLUDE_DEPRECATED_BEFORE_AND_AT=5.94.0
        -DQtWaylandScanner_EXECUTABLE=${CURRENT_INSTALLED_DIR}/tools/qt5-wayland/bin/qtwaylandscanner
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        QtWaylandScanner_EXECUTABLE
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME KF5GuiAddons CONFIG_PATH lib/cmake/KF5GuiAddons)
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSES/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")
