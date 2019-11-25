
include(GNUInstallDirs)

find_package(Eigen3 3.3.7
        NO_CMAKE_PACKAGE_REGISTRY
        PATHS ${H5PP_INSTALL_DIR_THIRD_PARTY}/eigen3/${CMAKE_INSTALL_LIBDIR}/cmake/eigen3
              ${EIGEN_INCLUDE_DIR} ${INSTALL_DIRECTORY}/Eigen3 $ENV{EBROOTEIGEN} $ENV{HOME}/.conda
              $ENV{HOME}/anaconda3 ${eigen3_DIR} ${DIRECTORY_HINTS}
        PATH_SUFFIXES Eigen3 eigen3 eigen3/${CMAKE_INSTALL_LIBDIR} eigen3/share eigen3/cmake)

if(TARGET Eigen3::Eigen)
    message(STATUS "Eigen3 found")
elseif (DOWNLOAD_MISSING)
    message(STATUS "Eigen3 will be installed into ${INSTALL_DIR_THIRD_PARTY}/Eigen3 on first build.")
    include(cmake-modules/BuildExternalLibs.cmake)
    build_external_libs(
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
        message(STATUS "Eigen3 installed successfully")
    else()
        message(STATUS "config_result: ${config_result}")
        message(STATUS "build_result: ${build_result}")
        message(FATAL_ERROR "Eigen3 could not be downloaded.")
    endif()

else()
    message(FATAL_ERROR "Dependency Eigen3 not found and DOWNLOAD_MISSING is OFF")

endif()