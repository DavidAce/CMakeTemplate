

################################################################
### Enforce an out-of-source build, because c'mon...         ###
################################################################
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
    message(STATUS "CMakeTemplate requires an out-of-source build.")
    message(STATUS "Please remove these files from ${CMAKE_BINARY_DIR} first:")
    message(STATUS "CMakeCache.txt")
    message(STATUS "CMakeFiles")
    message(STATUS "Once these files are removed, create a separate directory")
    message(STATUS "and run CMake from there")
    message(FATAL_ERROR "in-source build detected")
endif()
################################################################
### Enforce an out-of-source build, because c'mon...         ###
################################################################

#################################################################
### Set CMake version and policies for version >= 3.12        ###
#################################################################
cmake_minimum_required(VERSION 3.12 FATAL_ERROR)
cmake_policy(SET CMP0074 NEW)
cmake_policy(SET CMP0075 NEW)
cmake_policy(SET CMP0067 NEW)

#################################################################
### Set default flags. Override these with CMAKE_CXX_FLAGS_*  ###
#################################################################
set(CMAKE_USER_MAKE_RULES_OVERRIDE_CXX
        ${CMAKE_SOURCE_DIR}/cmake-modules/UserMakeRulesOverride.cxx.cmake)

#################################################################
### Setup project name and language                           ###
#################################################################
project(CMakeTemplate CXX)


#set(CMAKE_VERBOSE_MAKEFILE ON) #Only use for debugging
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${PROJECT_SOURCE_DIR}/cmake-modules)


################################################################
### Set options for compilation                              ###
################################################################
option(ENABLE_TESTS                 "Enables CTest testing"                                                           OFF)
option(ENABLE_TESTS_POST_BUILD      "Enables CTest testing directly after main build step (implies ENABLE_TESTS:ON)"  OFF)
option(BUILD_SHARED_LIBS            "Sets shared linking on/off"                                                      OFF)
option(ENABLE_EIGEN3                "Use Eigen3 Library. Guide with -DEIGEN_INCLUDE_DIR:PATH=<dir-to-eigen3>"         OFF)
option(ENABLE_SPDLOG                "Use SpdLog logging library. Guide with -Dspdlog_DIR:PATH=<dir-to-spdlog>"        OFF)
option(ENABLE_H5PP                  "Use h5pp, a C++ front-end to HDF5"                                               OFF)
option(ENABLE_OPENMP                "Enable OpenMP flags such as -fopenmp"                                            OFF)
option(DOWNLOAD_MISSING             "Download enabled libraries that aren't found"                                    OFF)
option(DOWNLOAD_METHOD_CMAKE        "Download missing libraries using CMake ExternalProjectAdd"                       ON)
option(DOWNLOAD_METHOD_CONAN        "Download missing libraries using Conan package manager"                          OFF)
option(ENABLE_CONANFILE             "Install software via the conan-modules/conanfile.txt"                            OFF)

#################################################################
### h5pp includes eigen and spdlog as a dependencies          ###
#################################################################
if(ENABLE_H5PP)
    message(STATUS "Eigen3 is included with h5pp -- disabling standalone Eigen3")
    set(ENABLE_EIGEN3 OFF)
    set(ENABLE_SPDLOG OFF)
endif()

#################################################################
### To do automatic tests after build, tests need to be on    ###
#################################################################
if(ENABLE_TESTS_POST_BUILD)
    set(ENABLE_TESTS ON)
endif()


if(ENABLE_EIGEN3 OR ENABLE_SPDLOG)
    if(ENABLE_CONANFILE)
        message(FATAL_ERROR "ENABLE_<lib> is incompatible with ENABLE_CONANFILE")
    endif()
endif()
#################################################################
### Initialize conan if enabled                               ###
#################################################################
if(DOWNLOAD_METHOD_CONAN)
    include(conan-modules/conan.cmake)
endif()





    ################################################################
### Get git version number                                   ###
### Generates a header gitversion/gitversion.h               ###
### Include it using #include <gitversion.h>                 ###
### Gives a namespace GIT:: with several git identifiers     ###
################################################################
include(cmake-modules/gitversion.cmake)



##################################################################
### Print operating system details                          ###
##################################################################
include(cmake-modules/PrintHostInfo.cmake)

##################################################################
### Print compiler details                                     ###
##################################################################
message("Compiling with: ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")



##################################################################
### Create a target with all the options you need to compile   ###
### NOTE: This should not contain 3rd party libraries, only    ###
### features and flags such as -O3, -fopenmp and -std=c++17    ###
##################################################################
add_library(project-settings INTERFACE)

##################################################################
### Setup compiler flags                                       ###
##################################################################
#if(NOT MARCH)
#    set(MARCH "native")
#endif()
#message("Using microarchitechture: ${MARCH}")
#set(COMMON_OPTIONS                      -g   -march=${MARCH} -mtune=${MARCH})
set(CMAKE_CXX_FLAGS_DEBUG          "-O0 -g3 -fstack-protector -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC -D_FORTIFY_SOURCE=2 -Wall -Wpedantic -Wextra")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O1 -march=native -mtune=native -g3 -fstack-protector -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC -D_FORTIFY_SOURCE=2 -Wall -Wpedantic -Wextra")
set(CMAKE_CXX_FLAGS_RELEASE        "-O3 -march=native -mtune=native -DNDEBUG ")
#



##################################################################
### Compiler-dependent compiler flags                          ###
##################################################################
if("${CMAKE_CXX_COMPILER_ID}" MATCHES "GNU" )
    list(APPEND PROFILE_OPTIONS -fopt-info -fopt-info-missed)
elseif("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
    list(APPEND COMMON_OPTIONS ${GCC_TOOLCHAIN})
    list(APPEND COMMON_OPTIONS -stdlib=libstdc++)
    list(APPEND PROFILE_OPTIONS  -Rpass-missed="loop|vect" )# -Rpass="loop|vect" -Rpass-analysis="loop|vect")
endif()



##################################################################
### Setup static/shared build and library suffixes (.a/.so)    ###
##################################################################
if(BUILD_SHARED_LIBS)
    set(CUSTOM_SUFFIX ${CMAKE_SHARED_LIBRARY_SUFFIX})
    set(CMAKE_FIND_LIBRARY_SUFFIXES ${CUSTOM_SUFFIX} ${CMAKE_FIND_LIBRARY_SUFFIXES})
else()
    set(CUSTOM_SUFFIX ${CMAKE_STATIC_LIBRARY_SUFFIX})
    set(CMAKE_FIND_LIBRARY_SUFFIXES ${CUSTOM_SUFFIX} ${CMAKE_FIND_LIBRARY_SUFFIXES})
    target_link_libraries(project-settings INTERFACE -static)
endif()


##################################################################
### Compiler-dependent linker flags                            ###
##################################################################
if("${CMAKE_CXX_COMPILER_ID}" MATCHES "GNU" )
    target_link_libraries(project-settings INTERFACE -lstdc++fs)  ### For experimental::filesystem
elseif("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
    target_link_libraries(project-settings INTERFACE -stdlib=libstdc++)  ### Because libc++ isn't up to speed...
    target_link_libraries(project-settings INTERFACE -lstdc++fs)         ### For experimental::filesystem
endif()



##################################################################
### Enable c++17 support and check new headers compile         ###
##################################################################
target_compile_features(project-settings INTERFACE cxx_std_17)
include(cmake-modules/CheckCXX17Compiles.cmake)


##################################################################
### Adapt pthread for static/dynamic linking                   ###
##################################################################
set(CMAKE_THREAD_PREFER_PTHREAD TRUE)
set(THREADS_PREFER_PTHREAD_FLAG FALSE)
find_package(Threads)
if(TARGET Threads::Threads AND NOT BUILD_SHARED_LIBS)
    set_target_properties(Threads::Threads PROPERTIES INTERFACE_LINK_LIBRARIES "-Wl,--whole-archive ${CMAKE_THREAD_LIBS_INIT} -Wl,--no-whole-archive")
endif()







#################################################################
### Add all source files recursively                           ###
##################################################################
add_executable(${PROJECT_NAME} source/main.cpp )
target_include_directories(${PROJECT_NAME} INTERFACE source)
target_include_directories(project-settings INTERFACE source)



##################################################################
### Check if we can enable Link Time Optimization              ###
##################################################################
include(CheckIPOSupported)
check_ipo_supported(RESULT supported OUTPUT error)
if(supported)
    message(STATUS "IPO / LTO supported, enabling")
    set_target_properties(${PROJECT_NAME} PROPERTIES INTERPROCEDURAL_OPTIMIZATION ON)
else()
    message(STATUS "IPO / LTO not supported: <${error}>, will not enable")
endif()



##################################################################
###  Optional OpenMP support                                   ###
###  Note that Clang has some trouble with static openmp       ###
###  We can solve this by trying to use its omp.h header       ###
###  linked together with intel omp library, libiomp5.a        ###
##################################################################
if(ENABLE_OPENMP)
    include(cmake-modules/CheckOMPCompiles.cmake)
    if(TARGET OpenMP)
        message(STATUS "Enabling OpenMP")
        target_link_libraries(project-settings INTERFACE OpenMP)
    else()
        message(STATUS "Disabling OpenMP -- Could not generate target OpenMP")
        set(ENABLE_OPENMP OFF)
        target_compile_options(project-settings INTERFACE -Wno-unknown-pragmas)
    endif()
endif()


##################################################################
### Setup dependency paths                                     ###
##################################################################
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX "${PROJECT_SOURCE_DIR}/libs" CACHE PATH "..." FORCE)
endif()

include(GNUInstallDirs)
if(NOT EXTERNAL_INSTALL_DIR)
    set(EXTERNAL_INSTALL_DIR   ${CMAKE_INSTALL_PREFIX})
endif()
set(EXTERNAL_BUILD_DIR         ${CMAKE_BINARY_DIR}/external-build)
set(EXTERNAL_CONFIG_DIR        ${CMAKE_BINARY_DIR}/external-config)



##################################################################
### Install conan-modules/conanfile.txt dependencies           ###
##################################################################



if(ENABLE_CONANFILE)
    message(WARNING "Using conanfile is still experimental.\n Manually edit this file if linking fails")
    include(conan-modules/conan.cmake)
    conan_cmake_run(CONANFILE conan-modules/conanfile.txt
            BASIC_SETUP CMAKE_TARGETS
            BUILD missing)
    target_link_libraries(${PROJECT_NAME} PRIVATE ${CONAN_TARGETS})
endif()


##################################################################
### Fetch or find enabled dependencies                         ###
##################################################################
if (ENABLE_SPDLOG)
    include(cmake-modules/Fetch_spdlog.cmake)
endif()
if (ENABLE_EIGEN3)
    include(cmake-modules/Fetch_Eigen3.cmake)
endif()

if (ENABLE_H5PP)
    include(cmake-modules/Fetch_h5pp.cmake)
endif()



##################################################################
### Apply all settings to current project                      ###
##################################################################
target_link_libraries(${PROJECT_NAME} PUBLIC project-settings)





##################################################################
### Link all generated targets to this project                 ###
##################################################################

if (TARGET spdlog::spdlog AND ENABLE_SPDLOG)
    target_link_libraries(${PROJECT_NAME} PRIVATE spdlog::spdlog)
endif()

if (TARGET h5pp::h5pp AND TARGET h5pp::deps AND ENABLE_H5PP)
    target_link_libraries(${PROJECT_NAME} PRIVATE h5pp::h5pp h5pp::deps)
endif()




##################################################################
### Print summary of CMake configuration                       ###
##################################################################
if(ENABLE_OPENMP OR ENABLE_SPDLOG OR ENABLE_H5PP OR ENABLE_EIGEN3)
        message("=============================================================================")
        message("===                  SUMMARY OF CMAKE CONFIGURATION                       ===")
        message("=============================================================================")
        include(cmake-modules/PrintTargetInfo.cmake)
        print_target_info(spdlog::spdlog)
        print_target_info(Eigen3::Eigen)
        print_target_info(h5pp::h5pp)
        print_target_info(h5pp::deps)
        print_target_info(OpenMP)
        print_target_info(project-settings)
        print_target_info(${PROJECT_NAME})
        message("=============================================================================")
    message("")
endif()




##################################################################
### Unit testing                                               ###
##################################################################
include(tests/all-tests.cmake)



##################################################################
### Print general information about next steps                 ###
##################################################################
message("")
message("=============================================================================")
message("")
message("      To clean cmake files, run './build.sh --clear-cmake'")
message("      To clean downloaded libraries, run './build.sh --clear-libs=all '")
message("      For more info, run ./build.sh --help '")
message("")
message("=============================================================================")
message("")

