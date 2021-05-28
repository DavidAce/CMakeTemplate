
cmake_minimum_required(VERSION 3.14)

### Setup project name and language
project(CMT VERSION 1.0
        DESCRIPTION "A CMake project template"
        HOMEPAGE_URL "https://github.com/DavidAce/CMakeTemplate"
        LANGUAGES CXX)

### Generate warnings if any are needed
include(cmake/DeprecationWarnings.cmake)


# Set default policies if CMake is new enough
if (CMAKE_VERSION VERSION_GREATER_EQUAL 3.12)
    cmake_policy(SET CMP0074 NEW) # To let find_package calls use <PackageName>_ROOT variables
    cmake_policy(SET CMP0075 NEW) # Include file check macros honor CMAKE_REQUIRED_LIBRARIES
    # Use cmake_policy CMP0067 to let try_compile honor current CMAKE_CXX_STANDARD setting.
    # See here https://stackoverflow.com/questions/47213356/cmake-using-corrext-c-standard-when-checking-for-header-files
    cmake_policy(SET CMP0067 NEW)
endif()


### Set options for compilation
option(BUILD_SHARED_LIBS               "Sets shared linking on/off"                                             OFF)
option(CMT_ENABLE_H5PP                 "Use h5pp, a C++ front-end to HDF5 (includes Eigen, fmt and spdlog)"     OFF)
option(CMT_ENABLE_EIGEN3               "Enables Eigen3 linear algebra library"                                  OFF)
option(CMT_ENABLE_FMT                  "Enables the {fmt} formatting library"                                   OFF)
option(CMT_ENABLE_THREADS              "Use C++11 stl threads e.g. in Eigen::Tensor"                            OFF)
option(CMT_ENABLE_OPENMP               "Enable OpenMP flags such as -fopenmp"                                   OFF)
option(CMT_ENABLE_LTO                  "Enable link time optimization"                                          OFF)
option(CMT_ENABLE_TESTS                "Enables CTest testing"                                                  OFF)
option(CMT_IS_SUBPROJECT               "Use CMT with add_subdirectory()"                                        OFF)
option(CMT_DEPS_IN_SUBDIR              "Install dependencies into CMAKE_INSTALL_PREFIX/<libname>"               OFF)
option(CMT_PRINT_INFO                  "Print info during cmake configuration"                                  OFF)
option(CMT_ENABLE_MPI                  "Enables use of MPI (work in progress)"                                  OFF)
option(CMT_ENABLE_ASAN                 "Enable runtime address sanitizer -fsanitize=address"                    OFF)
option(CMT_ENABLE_PCH                  "Enable precompiled headers (if supported) to speed up test compilation" ON)
option(CMT_ENABLE_CCACHE               "Enable ccache (if available) to speed up test compilation"              OFF)
option(CMAKE_POSITION_INDEPENDENT_CODE "Use -fPIC when compiling shared libraries"                              ON)

### h5pp includes eigen and spdlog as a dependencies
if(CMT_ENABLE_H5PP)
    message(STATUS "NOTE: Eigen3 and spdlog are included with h5pp")
    set(CMT_ENABLE_EIGEN3 OFF CACHE INTERNAL "CMT_ENABLE_H5PP:ON includes Eigen, Spdlog and fmt")
    set(CMT_ENABLE_SPDLOG OFF CACHE INTERNAL "CMT_ENABLE_H5PP:ON includes Eigen, Spdlog and fmt")
    set(CMT_ENABLE_FMT    OFF CACHE INTERNAL "CMT_ENABLE_H5PP:ON includes Eigen, Spdlog and fmt")
endif()


# Make an "enum" for valid package managers: find cmake find-or-cmake conan
set(CMT_PACKAGE_MANAGERS_VALID find fetch cmake find-or-cmake conan)
set(CMT_PACKAGE_MANAGER find CACHE STRING "Package manager for external dependencies")
set_property(CACHE CMT_PACKAGE_MANAGER PROPERTY STRINGS ${CMT_PACKAGE_MANAGERS_VALID})
if (NOT CMT_PACKAGE_MANAGER IN_LIST CMT_PACKAGE_MANAGERS_VALID)
    message(FATAL_ERROR "CMT_PACKAGE_MANAGER must be one of ${CMT_PACKAGE_MANAGERS_VALID}")
endif ()




# Used when this is a subproject (e.g., as Git submodule/subtree) in the source
# tree of a project that uses it. Users may set the option CMT_IS_SUBPROJECT
# before add_subdirectory(CMT)
if (NOT CMT_IS_SUBPROJECT)
    if ("^${CMAKE_SOURCE_DIR}$" STREQUAL "^${PROJECT_SOURCE_DIR}$")
        set(CMT_IS_SUBPROJECT OFF)
    else ()
        message(STATUS "Detected CMT as subproject")
        set(CMT_IS_SUBPROJECT ON)
    endif ()
endif ()


################################################################
### Get git version number                                   ###
### Generates a header gitversion/gitversion.h               ###
### Include it using #include <gitversion.h>                 ###
### Gives a namespace GIT:: with several git identifiers     ###
################################################################
include(cmake/gitversion.cmake)

### Print operating system details
include(cmake/PrintHostInfo.cmake)
### Print info about options
include(cmake/PrintOptionInfo.cmake)


### Create a helper target with all the options you need to compile
add_library(cmt-settings INTERFACE)


### Create a helper target with all the dependencies
add_library(cmt-dependencies INTERFACE)


### Add all source files
add_executable(${PROJECT_NAME} source/main.cpp )
target_include_directories(${PROJECT_NAME} PRIVATE source)
set_target_properties(${PROJECT_NAME} PROPERTIES LINK_WHAT_YOU_USE TRUE)




### Force cmake to find static library suffixes on static builds
### Reason: Some third party lib-config.cmake scripts have the bad habit
### of injecting shared libs into static builds
if(BUILD_SHARED_LIBS)
    set(LINK_TYPE SHARED)
else()
    set(LINK_TYPE STATIC)
    set(CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_STATIC_LIBRARY_SUFFIX} )
    if(NOT CMT_ENABLE_ASAN)
        target_link_libraries  (${PROJECT_NAME} PUBLIC -static)   ### Static linkage
    endif()
endif()



# Settings for sanitizers           ###
if(CMT_ENABLE_ASAN)
    target_compile_options(cmt-settings INTERFACE -fsanitize=address -fno-omit-frame-pointer)
    target_link_libraries(cmt-settings INTERFACE  -fsanitize=address)
    if(NOT BUILD_SHARED_LIBS)
        target_link_libraries(cmt-settingsINTERFACE -static-libasan)
    endif()
endif()
if(CMT_ENABLE_USAN)
    target_compile_options(cmt-settings INTERFACE -fsanitize=undefined -fno-omit-frame-pointer)
    target_link_libraries(cmt-settings INTERFACE -fsanitize=undefined)
endif()



##################################################################
### Preempt Threads::Threads                                   ###
### It's looked for in dependencies, so we make it right       ###
### before it's done wrong, i.e. with pthread instead of       ###
### -lpthread.                                                 ###
### Here we specify the linking twice                          ###
### 1) As string to make sure -lpthread gets sandwiched by     ###
###    -Wl,--whole-archive.... -Wl,--no-whole-archive          ###
### 2) As usual to make sure that if somebody links            ###
###    Threads::Threads, then any repeated pthread appended    ###
###    to the end (the wrong order causes linking errors)      ###
##################################################################
if(NOT TARGET Threads::Threads)
    set(THREADS_PREFER_PTHREAD_FLAG TRUE)
    find_package(Threads)
    target_link_libraries(Threads::Threads INTERFACE -Wl,--allow-multiple-definition,--whole-archive,-lpthread,--no-whole-archive)
    target_link_libraries(Threads::Threads INTERFACE rt dl)
endif()



### Fetch or find all the dependencies
include(cmake/SetupSearchPaths.cmake)
include(cmake/SetupDependenciesFetch.cmake)
include(cmake/SetupDependenciesCMake.cmake)
include(cmake/SetupDependenciesConan.cmake)

### Link all the things!
target_link_libraries(${PROJECT_NAME} PRIVATE cmt-settings cmt-dependencies)  # Link everything to main project

# Print summary of CMake configuration
if (CMT_PRINT_INFO)
    include(cmake/PrintTargetInfo.cmake)
    include(cmake/getExpandedTarget.cmake)
    message(STATUS "| CMT TARGET SUMMARY")
    message(STATUS "|-------------------")
    print_compiler_info("| ")
    expand_target_all_targets(${PROJECT_NAME} CMT_TARGET_EXPANDED)
    expand_target_all_targets(cmt-settings CMT_SETTINGS_TARGET_EXPANDED)
    expand_target_all_targets(cmt-dependencies CMT_DEPENDENCIES_TARGET_EXPANDED)
    foreach(tgt ${CMT_TARGET_EXPANDED})
        print_target_info(${tgt} "| ")
    endforeach()
    foreach(tgt ${CMT_SETTINGS_TARGET_EXPANDED})
        print_target_info(${tgt} "| ")
    endforeach()
    foreach(tgt ${CMT_DEPENDENCIES_TARGET_EXPANDED})
        print_target_info(${tgt} "| ")
    endforeach()
    mark_as_advanced(CMT_TARGET_EXPANDED)
    mark_as_advanced(CMT_SETTINGS_TARGET_EXPANDED)
    mark_as_advanced(CMT_DEPENDENCIES_TARGET_EXPANDED)
endif()


### Check if we can enable Link Time Optimization
if(CMT_ENABLE_LTO)
    include(CheckIPOSupported)
    check_ipo_supported(RESULT supported OUTPUT error)
    if(supported)
        message(STATUS "IPO / LTO supported, enabling")
        set_target_properties(${PROJECT_NAME} PROPERTIES INTERPROCEDURAL_OPTIMIZATION ON)
    else()
        message(STATUS "IPO / LTO not supported: <${error}>, will not enable")
        set(CMT_ENABLE_LTO OFF CACHE STRING "IPO/LTO not supported")
    endif()
endif()




##################################################################
### Speed up compilation with precompiled headers              ###
##################################################################
if(CMT_ENABLE_PCH)
    if(COMMAND target_precompile_headers)
        target_precompile_headers(cmt-settings INTERFACE <string> <vector> <array> <optional> <memory>)
        target_precompile_headers(${PROJECT_NAME} PRIVATE <string>)
    endif()
endif()

#######################################
# Settings for ccache               ###
#######################################
if(CMT_ENABLE_CCACHE)
    set(COMPILER_OK ON)
    if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        target_compile_options(cmt-settings INTERFACE -Xclang -fno-pch-timestamp)
        target_compile_options(${PROJECT_NAME} PRIVATE -Xclang -fno-pch-timestamp)
    endif()

    mark_as_advanced(COMPILER_OK)
    if(CMAKE_CXX_COMPILER_ID MATCHES "Clang" AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS "10.0.0")
        set(COMPILER_OK OFF)
    endif()
    if(COMPILER_OK)
        find_program(CCACHE_PROGRAM ccache)
        if(CCACHE_PROGRAM)
            set_target_properties(${PROJECT_NAME} PROPERTIES CXX_COMPILER_LAUNCHER ${CCACHE_PROGRAM})
            set_target_properties(cmt-settings PROPERTIES CXX_COMPILER_LAUNCHER ${CCACHE_PROGRAM})
            message(STATUS "Using ccache ${CCACHE_PROGRAM}")
            if(CMT_ENABLE_PCH AND COMMAND target_precompile_headers)
                message(STATUS "Detected ccache + pch: Remember to set --> sloppiness = include_file_mtime,pch_defines,time_macros <-- in your ccache.conf")
            endif()
        else()
            message(STATUS "ccache program could not be found")
        endif()
    endif()
endif()




## CTest
if (CMT_ENABLE_TESTS AND NOT CMT_IS_SUBPROJECT)
    enable_testing()
    add_subdirectory(tests)
endif ()



