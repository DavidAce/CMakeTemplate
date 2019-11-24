
include(GNUInstallDirs)

find_package(Eigen3 3.3.7
        NO_CMAKE_PACKAGE_REGISTRY
        PATHS ${H5PP_INSTALL_DIR_THIRD_PARTY}/eigen3/${CMAKE_INSTALL_LIBDIR}/cmake/eigen3
              ${EIGEN_INCLUDE_DIR} ${INSTALL_DIRECTORY}/Eigen3 $ENV{EBROOTEIGEN} $ENV{HOME}/.conda
              $ENV{HOME}/anaconda3 ${eigen3_DIR} ${DIRECTORY_HINTS}
        PATH_SUFFIXES Eigen3 eigen3 eigen3/${CMAKE_INSTALL_LIBDIR} eigen3/share eigen3/cmake)

if(TARGET Eigen3::Eigen)
    get_target_property(EIGEN3_INCLUDE_DIR Eigen3::Eigen INTERFACE_INCLUDE_DIRECTORIES)
    message(STATUS "Eigen3 found in system: ${EIGEN3_INCLUDE_DIR}")
elseif (DOWNLOAD_MISSING)
    message(STATUS "Eigen3 will be installed into ${INSTALL_DIR_THIRD_PARTY}/Eigen3 on first build.")
    include(cmake-modules/BuildThirdParty.cmake)
    build_third_party(
            "Eigen3"
            "${CONFIG_DIR_THIRD_PARTY}"
            "${BUILD_DIR_THIRD_PARTY}"
            "${INSTALL_DIR_THIRD_PARTY}"
            ""
    )
    message("Looking in: ${Eigen_INSTALL_DIR_THIRD_PARTY}/eigen3/${CMAKE_INSTALL_LIBDIR}/cmake/eigen3")
    find_package(Eigen3 3.3.7
            NO_DEFAULT_PATH NO_CMAKE_PACKAGE_REGISTRY
            PATHS ${INSTALL_DIR_THIRD_PARTY}/Eigen3/share/eigen3/cmake)
    if(Eigen3_FOUND AND TARGET Eigen3::Eigen)
        get_target_property(EIGEN3_INCLUDE_DIR Eigen3::Eigen INTERFACE_INCLUDE_DIRECTORIES)
        message(STATUS "Eigen3 installed successfully in : ${EIGEN3_INCLUDE_DIR}")
        #        include(cmake-modules/PrintTargetProperties.cmake)
        #        print_target_properties(eigen3::eigen3)
    else()
        message(STATUS "config_result: ${config_result}")
        message(STATUS "build_result: ${build_result}")
        message(FATAL_ERROR "Eigen3 could not be downloaded.")
    endif()

else()
    message(STATUS "Dependency Eigen3 not found and DOWNLOAD_MISSING is OFF")

endif()