cmake_minimum_required(VERSION 3.10)
project(external-h5pp)

include(ExternalProject)
ExternalProject_Add(external_h5pp
        GIT_REPOSITORY https://github.com/DavidAce/h5pp.git
        GIT_TAG master
        GIT_PROGRESS 1
        PREFIX      ${BUILD_DIR}/h5pp
        INSTALL_DIR ${INSTALL_DIR}/h5pp
        BUILD_ALWAYS OFF
        UPDATE_COMMAND ""
        CMAKE_ARGS
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DENABLE_TESTS:BOOL=ON
        -DTHIRD_PARTY_DIR:PATH=${INSTALL_DIR}
        -DDOWNLOAD_MISSING:BOOL=ON
        -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
        -DHDF5_DIR:PATH=${HDF5_DIR}
        -DHDF5_ROOT:PATH=${HDF5_DIR}
        -DEigen3_DIR:PATH=${Eigen3_DIR}
        -DEIGEN3_ROOT_DIR:PATH=${EIGEN3_ROOT_DIR}
        -DEIGEN3_INCLUDE_DIR:PATH=${EIGEN3_INCLUDE_DIR}
        -Dspdlog_DIR:PATH=${spdlog_DIR}
        -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
        )