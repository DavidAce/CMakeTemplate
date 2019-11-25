
include(GNUInstallDirs)

find_package(Eigen3 3.3.7
        NO_CMAKE_PACKAGE_REGISTRY
        PATHS ${EXTERNAL_INSTALL_DIR}/Eigen3/share/eigen3/cmake
              ${EIGEN_INCLUDE_DIR} ${INSTALL_DIRECTORY}/Eigen3 $ENV{EBROOTEIGEN} $ENV{HOME}/.conda
              $ENV{HOME}/anaconda3 ${eigen3_DIR} ${DIRECTORY_HINTS}
        PATH_SUFFIXES Eigen3 eigen3 eigen3/${CMAKE_INSTALL_LIBDIR} eigen3/share eigen3/cmake)

if(TARGET Eigen3::Eigen)
    message(STATUS "Eigen3 found")
elseif (DOWNLOAD_MISSING)
    message(STATUS "Eigen3 will be installed into ${EXTERNAL_INSTALL_DIR}/Eigen3 on first build.")
    include(cmake-modules/BuildExternalLibs.cmake)
    build_external_libs(
            "Eigen3"
            "${EXTERNAL_CONFIG_DIR}"
            "${EXTERNAL_BUILD_DIR}"
            "${EXTERNAL_INSTALL_DIR}"
            ""
    )
    message("Looking in: ${EXTERNAL_INSTALL_DIR}/Eigen3/share/eigen3/cmake")
    find_package(Eigen3 3.3.7
            NO_DEFAULT_PATH NO_CMAKE_PACKAGE_REGISTRY
            PATHS ${EXTERNAL_INSTALL_DIR}/Eigen3/share/eigen3/cmake)
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