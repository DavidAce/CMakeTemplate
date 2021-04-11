cmake_minimum_required(VERSION 3.12)
cmake_policy(SET CMP0074 NEW)
project(external-h5pp)


option(BUILD_SHARED_LIBS               "Builds shared libraries"                                     OFF)
option(H5PP_BUILD_EXAMPLES             "Builds examples"                                             OFF)
option(H5PP_ENABLE_TESTS               "Enable testing"                                              ON)
option(H5PP_DEPS_IN_SUBDIR             "Install dependencies into CMAKE_INSTALL_PREFIX/<libname>"    ON)
option(H5PP_PREFER_CONDA_LIBS          "Search for dependencies from anaconda first"                 OFF)
option(H5PP_PRINT_INFO                 "Print info during cmake configuration"                       ON)
option(H5PP_ENABLE_EIGEN3              "Enables Eigen3 linear algebra library"                       ON)
option(H5PP_ENABLE_FMT                 "Enables the {fmt} formatting library"                        ON)
option(H5PP_ENABLE_SPDLOG              "Enables Spdlog for logging h5pp internal info to stdout"     ON)
option(H5PP_ENABLE_MPI                 "Enables use of MPI (work in progress)"                       OFF)
option(H5PP_ENABLE_ASAN                "Enable runtime address sanitizer -fsanitize=address"         OFF)
option(CMAKE_POSITION_INDEPENDENT_CODE "Use -fPIC when compiling shared libraries"                   ON)


include(ExternalProject)
ExternalProject_Add(external_h5pp
        GIT_REPOSITORY https://github.com/DavidAce/h5pp.git
        GIT_TAG dev
        GIT_PROGRESS TRUE
        GIT_SHALLOW TRUE
        BUILD_ALWAYS TRUE
        PREFIX          ${CMAKE_BINARY_DIR}
        INSTALL_DIR     ${CMAKE_INSTALL_PREFIX}
        CMAKE_ARGS
        # CMake flags
        ${CMAKE_CXX_COMPILER_LOADED}
        -DCMAKE_POLICY_DEFAULT_CMP0074=${CMAKE_POLICY_DEFAULT_CMP0074}
        -DCMAKE_EXE_LINKER_FLAGS_INIT=${CMAKE_EXE_LINKER_FLAGS}
        -DCMAKE_SHARED_LINKER_FLAGS_INIT=${CMAKE_SHARED_LINKER_FLAGS}
        -DCMAKE_STATIC_LINKER_FLAGS_INIT=${CMAKE_STATIC_LINKER_FLAGS}
        -DCMAKE_MODULE_LINKER_FLAGS_INIT=${CMAKE_MODULE_LINKER_FLAGS}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
        -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=${CMAKE_POSITION_INDEPENDENT_CODE}
        -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
        -DCMAKE_CXX_STANDARD=${CMAKE_CXX_STANDARD}
        -DCMAKE_CXX_STANDARD_REQUIRED:BOOL=${CMAKE_CXX_STANDARD_REQUIRED}
        -DCMAKE_CXX_EXTENSIONS:BOOL=${CMAKE_CXX_EXTENSIONS}
        -DCMAKE_CXX_FLAGS_INIT:STRING=${CMAKE_CXX_FLAGS}
        -DCMAKE_CXX_FLAGS_RELEASE_INIT:STRING=${CMAKE_CXX_FLAGS_RELEASE}
        -DCMAKE_CXX_FLAGS_DEBUG_INIT:STRING=${CMAKE_CXX_FLAGS_DEBUG}
        -DCMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT:STRING=${CMAKE_CXX_FLAGS_RELWITHDEBINFO}
        -DCMAKE_CXX_FLAGS_MINSIZEREL_INIT:STRING=${CMAKE_CXX_FLAGS_MINSIZEREL}
        -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
        -DCMAKE_INSTALL_MESSAGE=${CMAKE_INSTALL_MESSAGE}
        -DCMAKE_GENERATOR=${CMAKE_GENERATOR}
        -DCMAKE_GENERATOR_PLATFORM=${CMAKE_GENERATOR_PLATFORM}
        -DCMAKE_BUILD_WITH_INSTALL_RPATH:BOOL=TRUE
        -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=TRUE
#        -DCMAKE_FIND_DEBUG_MODE:BOOL=ON
        # h5pp flags
        -DH5PP_BUILD_EXAMPLES:BOOL=${H5PP_BUILD_EXAMPLES}
        -DH5PP_ENABLE_TESTS:BOOL=${H5PP_ENABLE_TESTS}
        -DH5PP_DEPS_IN_SUBDIR:BOOL=${H5PP_DEPS_IN_SUBDIR}
        -DH5PP_PREFER_CONDA_LIBS:BOOL=${H5PP_PREFER_CONDA_LIBS}
        -DH5PP_PRINT_INFO:BOOL=${H5PP_PRINT_INFO}
        -DH5PP_ENABLE_EIGEN3:BOOL=${H5PP_ENABLE_EIGEN3}
        -DH5PP_ENABLE_FMT:BOOL=${H5PP_ENABLE_FMT}
        -DH5PP_ENABLE_SPDLOG:BOOL=${H5PP_ENABLE_SPDLOG}
        -DH5PP_ENABLE_MPI:BOOL=${H5PP_ENABLE_MPI}
        -DH5PP_ENABLE_ASAN:BOOL=${H5PP_ENABLE_ASAN}
        -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=${CMAKE_POSITION_INDEPENDENT_CODE}
        -DH5PP_PACKAGE_MANAGER:STRING=${H5PP_PACKAGE_MANAGER}
        -DEigen3_ROOT:PATH=${Eigen3_ROOT}
        )