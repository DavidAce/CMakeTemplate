
cmake_minimum_required(VERSION 3.24)

### Setup project name and language
project(CMT VERSION 1.1
        DESCRIPTION "A CMake project template"
        HOMEPAGE_URL "https://github.com/DavidAce/CMakeTemplate"
        LANGUAGES CXX)


### Set options
option(CMT_ENABLE_OPENMP "Enable OpenMP flags such as -fopenmp"   OFF)
option(CMT_ENABLE_MPI    "Enables use of MPI (work in progress)"  OFF)
option(CMT_ENABLE_TESTS  "Enables CTest testing"                  OFF)
option(CMT_CMAKE_DEBUG   "Print info during CMake configuration"  OFF)



################################################################
### Get git version number                                   ###
### Generates a header gitversion/gitversion.h               ###
### Include it using #include <gitversion.h>                 ###
### Gives a namespace GIT:: with several git identifiers     ###
################################################################
include(cmake/gitversion.cmake)


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
set_target_properties(CMT PROPERTIES LINK_WHAT_YOU_USE TRUE)


### Create a helper targets that can be reused to build tests
add_library(cmt-libs INTERFACE)
add_library(cmt-flags INTERFACE)
include(cmake/CompilerFlags.cmake)



### Find dependencies
find_package(h5pp   1.11.0 REQUIRED)
find_package(Eigen3 3.4.0  REQUIRED)
target_link_libraries(cmt-libs INTERFACE h5pp::h5pp Eigen3::Eigen)

if(CMT_ENABLE_OPENMP)
    find_package(OpenMP COMPONENTS CXX REQUIRED) # Uses DMRG's own find module
    target_link_libraries(cmt-libs INTERFACE OpenMP::OpenMP_CXX)
endif()

if(CMT_ENABLE_MPI)
    find_package(MPI COMPONENTS CXX REQUIRED) # Uses DMRG's own find module
    target_link_libraries(cmt-libs INTERFACE MPI::MPI_CXX)
endif()



### Link to executable
target_link_libraries(CMT PUBLIC cmt-libs cmt-flags)  # Link everything to main project


### CTest
if(CMT_ENABLE_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()


if(CMT_CMAKE_DEBUG)
    # Print summary of CMake configuration
    include(cmake/PrintTargetInfo.cmake)
    print_and_write_project_summary(CMT)
endif()
