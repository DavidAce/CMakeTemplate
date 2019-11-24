cmake_minimum_required(VERSION 3.10)
project(external-Eigen3)

include(ExternalProject)
ExternalProject_Add(external_Eigen3
        GIT_REPOSITORY https://github.com/eigenteam/eigen-git-mirror.git
        GIT_TAG 3.3.7
        GIT_PROGRESS false
        GIT_SHALLOW true
        PATCH_COMMAND git apply ${SELF_DIR}/Eigen_3.3.7.patch
        PREFIX      ${BUILD_DIR}/Eigen3
        INSTALL_DIR ${INSTALL_DIR}/Eigen3
        CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
        -DCMAKE_INSTALL_MESSAGE=NEVER #Avoid unnecessary output to console, like up-to-date and installing
        UPDATE_COMMAND ""
        TEST_COMMAND ""
        )