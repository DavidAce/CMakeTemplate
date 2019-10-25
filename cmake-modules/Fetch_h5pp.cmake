
find_package(h5pp PATHS ${INSTALL_DIR_THIRD_PARTY}/h5pp $ENV{H5PP_DIR})

if(h5pp_FOUND AND TARGET h5pp::h5pp)
    message(STATUS "h5pp FOUND IN SYSTEM: ${H5PP_ROOT}")
#    add_library(h5pp ALIAS h5pp::h5pp)
else()
    message(STATUS "h5pp will be installed into ${INSTALL_DIR_THIRD_PARTY}/h5pp")
    include(cmake-modules/BuildThirdParty.cmake)
    build_third_party(
            "h5pp"
            "${CONFIG_DIR_THIRD_PARTY}"
            "${BUILD_DIR_THIRD_PARTY}"
            "${INSTALL_DIR_THIRD_PARTY}"
            "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}"
    )
    find_package(h5pp PATHS ${INSTALL_DIR_THIRD_PARTY}/h5pp $ENV{H5PP_DIR})
    if(h5pp_FOUND AND TARGET h5pp::h5pp)
        message(STATUS "h5pp installed successfully: ${H5PP_ROOT}")
        else()
        message(STATUS "config_result: ${config_result}")
        message(STATUS "build_result: ${build_result}")
        message(FATAL_ERROR "h5pp could not be downloaded.")
    endif()

endif()
