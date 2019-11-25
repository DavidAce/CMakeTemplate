project(CMakeTemplate CXX)
cmake_minimum_required(VERSION 3.12)

set(CMAKE_VERBOSE_MAKEFILE OFF)
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
#option(RECOMMENDED_COMPILER_FLAGS   "Apply recommended compiler flags"                                                OFF)

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



#################################################################
### Set default policies if for CMake version >= 3.12         ###
#################################################################
cmake_policy(SET CMP0074 NEW)
cmake_policy(SET CMP0075 NEW)
cmake_policy(SET CMP0067 NEW)



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
if(NOT MARCH)
    set(MARCH "native")
endif()
message("Using microarchitechture: ${MARCH}")
set(COMMON_OPTIONS            -g -Wall -Wpedantic -Wextra  -march=${MARCH} -mtune=${MARCH})
set(DEBUG_OPTIONS             -O0 -g3 -fstack-protector -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC -D_FORTIFY_SOURCE=2)
set(RELWITHDEBINFO_OPTIONS    -O1 -g3 -fstack-protector -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC -D_FORTIFY_SOURCE=2)
set(RELEASE_OPTIONS           -O3 -DNDEBUG )
set(PROFILE_OPTIONS           -O3 -DNDEBUG  -lprofiler -g  -ftime-report)




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
set(COMPILER_LFLAGS)
if(BUILD_SHARED_LIBS)
    set(CUSTOM_SUFFIX ${CMAKE_SHARED_LIBRARY_SUFFIX})
    set(CMAKE_FIND_LIBRARY_SUFFIXES ${CUSTOM_SUFFIX} ${CMAKE_FIND_LIBRARY_SUFFIXES})
else()
    set(CUSTOM_SUFFIX ${CMAKE_STATIC_LIBRARY_SUFFIX})
    set(CMAKE_FIND_LIBRARY_SUFFIXES ${CUSTOM_SUFFIX} ${CMAKE_FIND_LIBRARY_SUFFIXES})
    list(APPEND COMPILER_LFLAGS -static)        ### Static linkage
endif()


##################################################################
### Compiler-dependent linker flags                            ###
##################################################################
if("${CMAKE_CXX_COMPILER_ID}" MATCHES "GNU" )
    list(APPEND COMPILER_LFLAGS -lstdc++fs)     ### For experimental::filesystem
    list(APPEND COMPILER_LFLAGS -flto)          ### Link time optimization flag
elseif("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
    list(APPEND COMPILER_LFLAGS -stdlib=libstdc++)
    list(APPEND COMPILER_LFLAGS -lstdc++fs)        ### For experimental::filesystem
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


##################################################################
### Apply all settings to helper target                        ###
##################################################################
target_compile_options (project-settings INTERFACE
        ${COMMON_OPTIONS}
        "$<$<CONFIG:DEBUG>:${DEBUG_OPTIONS}>"
        "$<$<CONFIG:RELWITHDEBINFO>:${RELWITHDEBINFO_OPTIONS}>"
        "$<$<CONFIG:RELEASE>:${RELEASE_OPTIONS}>"
        "$<$<CONFIG:PROFILE>:${PROFILE_OPTIONS}>"
        )
target_link_libraries(project-settings INTERFACE ${COMPILER_LFLAGS})
target_include_directories(project-settings INTERFACE source)




#################################################################
### Add all source files recursively                           ###
##################################################################
file(GLOB_RECURSE SOURCES CONFIGURE_DEPENDS "source/*.cpp" )
file(GLOB_RECURSE HEADERS CONFIGURE_DEPENDS "source/*.h"  )
add_executable(${PROJECT_NAME} ${SOURCES} ${HEADERS})


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
if(THIRD_PARTY_DIR)
    set(INSTALL_DIR_THIRD_PARTY       ${THIRD_PARTY_DIR})
else()
    set(INSTALL_DIR_THIRD_PARTY       ${CMAKE_INSTALL_PREFIX})
endif()
set(BUILD_DIR_THIRD_PARTY         ${CMAKE_BINARY_DIR}/third-party-build)
set(CONFIG_DIR_THIRD_PARTY        ${CMAKE_BINARY_DIR}/third-party-config)



if (ENABLE_SPDLOG)
    include(cmake-modules/Fetch_spdlog.cmake)
endif()

if (ENABLE_H5PP)
    include(cmake-modules/Fetch_h5pp.cmake)
endif()

if (ENABLE_EIGEN3)
    include(cmake-modules/Fetch_Eigen3.cmake)
endif()


##################################################################
### Apply all settings to current project                      ###
##################################################################
target_link_libraries(${PROJECT_NAME} PUBLIC project-settings)




##################################################################
### Link all generated targets to this project                 ###
##################################################################
target_link_libraries(${PROJECT_NAME} PRIVATE ${COMPILER_LFLAGS})

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

