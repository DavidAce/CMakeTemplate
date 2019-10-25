
find_package(h5pp PATHS ${INSTALL_DIRECTORY}/h5pp $ENV{H5PP_DIR})

if(h5pp_FOUND AND TARGET h5pp::h5pp)
    message(STATUS "h5pp FOUND IN SYSTEM: ${H5PP_ROOT}")
#    add_library(h5pp ALIAS h5pp::h5pp)
else()
    message(STATUS "h5pp will be installed into ${INSTALL_DIRECTORY}/h5pp")
    include(cmake-modules/BuildThirdParty.cmake)
    build_third_party(
            "h5pp"
            "${CONFIG_DIR_THIRD_PARTY}"
            "${BUILD_DIR_THIRD_PARTY}"
            "${INSTALL_DIR_THIRD_PARTY}"
            "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}"
    )
    find_package(h5pp PATHS ${INSTALL_DIRECTORY}/h5pp $ENV{H5PP_DIR})
    if(h5pp_FOUND AND TARGET h5pp::h5pp)
        message(STATUS "h5pp installed successfully: ${H5PP_ROOT}")
        else()
        message(STATUS "config_result: ${config_result}")
        message(STATUS "build_result: ${build_result}")
        message(FATAL_ERROR "h5pp could not be downloaded.")
    endif()
    #
#    include(ExternalProject)
#    ExternalProject_Add(external_H5PP
#            GIT_REPOSITORY https://github.com/DavidAce/h5pp.git
#            GIT_TAG master
#            GIT_PROGRESS 1
#            PREFIX      ${BUILD_DIRECTORY}/h5pp
#            INSTALL_DIR ${INSTALL_DIRECTORY}/h5pp
#            BUILD_ALWAYS 1
#            UPDATE_COMMAND ""
#            CMAKE_ARGS
#            -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
#            -DENABLE_TESTS:BOOL=ON
#            -DTHIRD_PARTY_DIR:PATH=<INSTALL_DIR>
#            -DDOWNLOAD_MISSING:BOOL=ON
#            -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
#            -DHDF5_DIR:PATH=${HDF5_DIR}
#            -DHDF5_ROOT:PATH=${HDF5_DIR}
#            -DEigen3_DIR:PATH=${Eigen3_DIR}
#            -DEIGEN3_ROOT_DIR:PATH=${EIGEN3_ROOT_DIR}
#            -DEIGEN3_INCLUDE_DIR:PATH=${EIGEN3_INCLUDE_DIR}
#            -Dspdlog_DIR:PATH=${spdlog_DIR}
#            -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
#            )
#
#    ExternalProject_Get_Property(external_H5PP INSTALL_DIR)
#    add_library(h5pp INTERFACE)
##    add_library(deps INTERFACE)
##    add_library(flags INTERFACE)
#    add_library(h5pp::h5pp ALIAS h5pp)
#    add_library(h5pp::deps ALIAS h5pp)
#    add_library(h5pp::flags ALIAS h5pp)
#    target_link_libraries(h5pp  INTERFACE -lstdc++fs)
#    target_compile_options(h5pp  INTERFACE -std=c++17)
#    target_compile_features(h5pp INTERFACE cxx_std_17)
#
#    set(H5PP_INCLUDE_DIR ${INSTALL_DIR}/include)
#    add_dependencies(h5pp external_H5PP)
#    add_dependencies(h5pp Eigen3::Eigen spdlog::spdlog hdf5::hdf5)
#    target_link_libraries(h5pp INTERFACE Eigen3::Eigen spdlog::spdlog hdf5::hdf5)
#    target_include_directories(h5pp INTERFACE ${H5PP_INCLUDE_DIR})
endif()
