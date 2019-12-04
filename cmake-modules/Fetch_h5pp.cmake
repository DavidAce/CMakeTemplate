
find_package(h5pp 0.3.4
        PATHS ${CMAKE_INSTALL_PREFIX} ${CMAKE_BINARY_DIR}/deps-install $ENV{H5PP_DIR}
        PATH_SUFFIXES h5pp NO_CMAKE_PACKAGE_REGISTRY NO_DEFAULT_PATH)


if(TARGET h5pp::h5pp)
    message(STATUS "h5pp found")
elseif(DOWNLOAD_MISSING)
    message(STATUS "h5pp will be installed into ${CMAKE_INSTALL_PREFIX}")
    include(${PROJECT_SOURCE_DIR}/cmake-modules/BuildDependency.cmake)
    build_dependency(h5pp)
    find_package(h5pp PATHS ${EXTERNAL_INSTALL_DIR}/h5pp $ENV{H5PP_DIR})
    find_package(h5pp 0.3.4
            PATHS ${CMAKE_BINARY_DIR}/deps-install $ENV{H5PP_DIR}
            PATH_SUFFIXES h5pp NO_CMAKE_PACKAGE_REGISTRY NO_DEFAULT_PATH)

    if(TARGET h5pp::h5pp)
        message(STATUS "h5pp installed successfully")
        else()
        message(STATUS "config_result: ${config_result}")
        message(STATUS "build_result: ${build_result}")
        message(FATAL_ERROR "h5pp could not be downloaded.")
    endif()
else()
    message(FATAL_ERROR "Dependency h5pp not found and DOWNLOAD_MISSING is OFF")
endif()
