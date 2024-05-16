
cmake_minimum_required(VERSION 3.24)

### Setup project name and language
project(CMT VERSION 1.2
        DESCRIPTION "A CMake project template"
        HOMEPAGE_URL "https://github.com/DavidAce/CMakeTemplate"
        LANGUAGES C CXX)


### Set up options
option(CMT_ENABLE_OPENMP   "Enable OpenMP flags such as -fopenmp"                 OFF)
option(CMT_ENABLE_MPI      "Enables use of MPI (work in progress)"                OFF)
option(CMT_ENABLE_COVERAGE "Adds the --coverage flag (used with github actions)"  OFF)
option(CMT_BUILD_BENCH     "Builds benchmarks in ./bench"                         OFF)
option(CMT_BUILD_EXAMPLES  "Builds examples in ./examples"                        OFF)
option(CMT_BUILD_TESTS     "Builds unit tests in ./tests"                         OFF)
option(CMT_CMAKE_DEBUG     "Print info during CMake configuration"                OFF)



if(CMT_DEBUG_CMAKE)
    ### Print operating system details
    include(cmake/PrintHostInfo.cmake)
endif()

### Add all source files
add_executable(CMT
        source/main.cpp 
        # ...
        )

target_include_directories(CMT PRIVATE source)


### Find dependencies
find_package(h5pp       1.11.1  REQUIRED)
find_package(Eigen3     3.4.0   REQUIRED)
find_package(spdlog     1.13.0  REQUIRED)
find_package(pcg-cpp            REQUIRED)
find_package(doctest    2.4.1   REQUIRED)
find_package(nanobench  4.3.11  REQUIRED)
find_package(CLI11      2.3.2   REQUIRED)


### Create a helper target that links dependencies (this target can be used to build tests and benchmarks)
add_library(cmt-libs INTERFACE)

# Link the libraries to the helper target
target_link_libraries(cmt-libs INTERFACE h5pp::h5pp)
target_link_libraries(cmt-libs INTERFACE Eigen3::Eigen )
target_link_libraries(cmt-libs INTERFACE spdlog::spdlog )
target_link_libraries(cmt-libs INTERFACE pcg-cpp::pcg-cpp )
target_link_libraries(cmt-libs INTERFACE doctest::doctest)
target_link_libraries(cmt-libs INTERFACE nanobench::nanobench)
target_link_libraries(cmt-libs INTERFACE CLI11::CLI11)

if(CMT_ENABLE_OPENMP)
    find_package(OpenMP COMPONENTS CXX REQUIRED)
    target_link_libraries(cmt-libs INTERFACE OpenMP::OpenMP_CXX)
endif()

if(CMT_ENABLE_MPI)
    find_package(MPI COMPONENTS CXX REQUIRED)
    target_link_libraries(cmt-libs INTERFACE MPI::MPI_CXX)
endif()


### Link targets to the main executable
target_link_libraries(CMT PUBLIC cmt-libs)


################################################################
### Get git version number                                   ###
### Generates a header gitversion/gitversion.h               ###
### Include it using #include <gitversion.h>                 ###
### Gives a namespace GIT:: with several git identifiers     ###
################################################################
include(cmake/gitversion.cmake)

add_subdirectory(bench)    # Builds benchmarks if CMT_BUILD_BENCH==ON
add_subdirectory(examples) # Builds examples if CMT_BUILD_EXAMPLES==ON


### CTest
if(CMT_BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
    if(CMT_ENABLE_COVERAGE)
        # Coverage is used to check what fraction of the source code is tested
        # We use this option in the github actions when compiling on Ubuntu with gcc
        target_compile_options(cmt-libs INTERFACE --coverage)
        target_link_options(cmt-libs INTERFACE --coverage)
    endif()
endif()


if(CMT_CMAKE_DEBUG)
    # Print summary of CMake configuration
    include(cmake/PrintTargetInfo.cmake)
    print_and_write_project_summary(CMT)
endif()
