if(NOT TARGET h5pp::h5pp AND CMT_PACKAGE_MANAGER STREQUAL "find")
    find_package(h5pp
            HINTS ${CMAKE_INSTALL_PREFIX}
            1.8.0 NO_CMAKE_PACKAGE_REGISTRY)
    if(h5pp_FOUND AND TARGET h5pp::h5pp)
        message(STATUS "Found h5pp")
    endif()
endif()

if(NOT TARGET h5pp::h5pp AND CMT_PACKAGE_MANAGER MATCHES "cmake")
    find_package(h5pp  1.8.0
            HINTS ${CMAKE_INSTALL_PREFIX}
            NO_CMAKE_PACKAGE_REGISTRY)
    if(h5pp_FOUND AND TARGET h5pp::h5pp)
        message(STATUS "Found h5pp")
    endif()
endif()

if(NOT TARGET h5pp::h5pp AND CMT_PACKAGE_MANAGER MATCHES "cmake")
    message(STATUS "h5pp will be installed into ${CMAKE_INSTALL_PREFIX}")
    include(${PROJECT_SOURCE_DIR}/cmake/BuildDependency.cmake)
    list(APPEND H5PP_CMAKE_OPTIONS  -DEigen3_ROOT:PATH=${CMAKE_INSTALL_PREFIX}/Eigen3)
    list(APPEND H5PP_CMAKE_OPTIONS  -DH5PP_PACKAGE_MANAGER:BOOL=${CMT_PACKAGE_MANAGER})
    list(APPEND H5PP_CMAKE_OPTIONS  -DH5PP_PREFER_CONDA_LIBS:BOOL=${CMT_PREFER_CONDA_LIBS})
    list(APPEND H5PP_CMAKE_OPTIONS  -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE})
    build_dependency(h5pp "${CMAKE_INSTALL_PREFIX}" "${H5PP_CMAKE_OPTIONS}")
    find_package(h5pp 1.8.0
            HINTS ${CMAKE_INSTALL_PREFIX}
            NO_CMAKE_PACKAGE_REGISTRY)
    if(h5pp_FOUND AND TARGET h5pp::h5pp)
        message(STATUS "h5pp installed successfully")
    else()
        message(FATAL_ERROR "h5pp could not be installed")
    endif()
endif()
