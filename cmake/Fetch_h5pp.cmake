cmake_minimum_required(VERSION 3.12)

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


include(FetchContent)
FetchContent_Declare(h5pp
        GIT_REPOSITORY https://github.com/DavidAce/h5pp.git
        GIT_TAG v1.8.6
        GIT_PROGRESS TRUE
        GIT_SHALLOW TRUE
        BUILD_ALWAYS TRUE
        CMAKE_ARGS
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
        -DH5PP_PACKAGE_MANAGER=cmake
        -DEigen3_ROOT:PATH=${Eigen3_ROOT}
        )

FetchContent_MakeAvailable(h5pp)