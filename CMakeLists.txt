

### Enforce an out-of-source build, because c'mon...
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
    message(STATUS "CMakeTemplate requires an out-of-source build.")
    message(STATUS "Please remove these files from ${CMAKE_BINARY_DIR} first:")
    message(STATUS "CMakeCache.txt")
    message(STATUS "CMakeFiles")
    message(STATUS "Once these files are removed, create a separate directory")
    message(STATUS "and run CMake from there")
    message(FATAL_ERROR "in-source build detected")
endif()




### Set CMake version and policies for version >= 3.12
cmake_minimum_required(VERSION 3.12)

#cmake_policy(SET CMP0074 NEW)
#cmake_policy(SET CMP0075 NEW)
#cmake_policy(SET CMP0067 NEW)

### Set default flags. Override these with CMAKE_CXX_FLAGS_*
set(CMAKE_USER_MAKE_RULES_OVERRIDE_CXX
        ${CMAKE_CURRENT_SOURCE_DIR}/cmake-modules/UserMakeRulesOverride.cxx.cmake)


### Setup project name and language
project(CMakeTemplate CXX)


#set(CMAKE_VERBOSE_MAKEFILE ON) #Only use for debugging
list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake-modules)

### Set options for compilation
option(ENABLE_TESTS                 "Enables CTest testing"                                                           OFF)
option(BUILD_SHARED_LIBS            "Sets shared linking on/off"                                                      OFF)
option(ENABLE_EIGEN3                "Use Eigen3 Library. Guide with -DEIGEN_INCLUDE_DIR:PATH=<dir-to-eigen3>"         OFF)
option(ENABLE_SPDLOG                "Use SpdLog logging library. Guide with -Dspdlog_DIR:PATH=<dir-to-spdlog>"        OFF)
option(ENABLE_H5PP                  "Use h5pp, a C++ front-end to HDF5"                                               OFF)
option(ENABLE_OPENMP                "Enable OpenMP flags such as -fopenmp"                                            OFF)
option(DOWNLOAD_MISSING             "Download enabled libraries that aren't found"                                    OFF)
option(DOWNLOAD_METHOD_CMAKE        "Download missing libraries using CMake ExternalProjectAdd"                       ON)
option(DOWNLOAD_METHOD_CONAN        "Download missing libraries using Conan package manager"                          OFF)
option(ENABLE_CONANFILE             "Install software via the conan-modules/conanfile.txt"                            OFF)
option(ENABLE_LTO                   "Enable link time optimization"                                                   OFF)
option(AS_SUBPROJECT                "Try using this as a subproject with add_subdirectory()"                          OFF)
option(APPEND_LIBSUFFIX             "Append <libname> to CMAKE_INSTALL_PREFIX"                                        OFF)


### h5pp includes eigen and spdlog as a dependencies
if(ENABLE_H5PP)
    message(STATUS "NOTE: Eigen3 and spdlog are included with h5pp")
    set(ENABLE_EIGEN3 OFF)
    set(ENABLE_SPDLOG OFF)
endif()


### h5pp includes eigen and spdlog as a dependencies
if(ENABLE_EIGEN3 OR ENABLE_SPDLOG)
    if(ENABLE_CONANFILE)
        message(FATAL_ERROR "ENABLE_<lib> is incompatible with ENABLE_CONANFILE")
    endif()
endif()


# Used when h5pp is included as subproject (e.g., as Git submodule/subtree) in the source
# tree of a project that uses it. Users may set the non-cached variable AS_SUBPROJECT
# before add_subdirectory(h5pp)
if(NOT AS_SUBPROJECT)
    if("^${CMAKE_SOURCE_DIR}$" STREQUAL "^${PROJECT_SOURCE_DIR}$")
        set (AS_SUBPROJECT FALSE)
    else()
        message(STATUS "Detected usage as subproject")
        set (AS_SUBPROJECT TRUE)
    endif()
endif()


################################################################
### Get git version number                                   ###
### Generates a header gitversion/gitversion.h               ###
### Include it using #include <gitversion.h>                 ###
### Gives a namespace GIT:: with several git identifiers     ###
################################################################
include(cmake-modules/gitversion.cmake)


### Print operating system details
include(cmake-modules/PrintHostInfo.cmake)


### Print compiler details
message("Compiling with: ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")




### Create a helper target with all the options you need to compile
### This one is useful to pass to tests and examples so that they compile
### In the same way as our main project.
add_library(project-settings INTERFACE)



### Add all source files
add_executable(${PROJECT_NAME} source/main.cpp )
target_include_directories(${PROJECT_NAME} PRIVATE source)




if(ENABLE_LTO)
    ### Check if we can enable Link Time Optimization
    include(CheckIPOSupported)
    check_ipo_supported(RESULT supported OUTPUT error)
    if(supported)
        message(STATUS "IPO / LTO supported, enabling")
        set_target_properties(${PROJECT_NAME} PROPERTIES INTERPROCEDURAL_OPTIMIZATION ON)
    else()
        message(STATUS "IPO / LTO not supported: <${error}>, will not enable")
    endif()
endif()


###  Optional OpenMP support
###  Note that Clang has some  trouble with static openmp and that
###  and that static openmp is not recommended. This tries to enable
###  static openmp anyway because I find it useful. Installing
###  libiomp5 might help for shared linking.
if(ENABLE_OPENMP)
    include(cmake-modules/FindPackageOpenMP.cmake)
    find_package_openmp()
    if(TARGET OpenMP)
        target_link_libraries(project-settings INTERFACE OpenMP)
    else()
        target_compile_options(project-settings INTERFACE -Wno-unknown-pragmas)
    endif()
endif()



##################################################################
### Install conan-modules/conanfile.txt dependencies           ###
##################################################################
if(DOWNLOAD_METHOD_CONAN)
    ### Initialize conan if requested
    ### Note that this is not the same as enabling the conanfile
    ### This simply mean that we use conan to get spdlog/eigen3/h5pp
    include(conan-modules/conan.cmake)
endif()

if(ENABLE_CONANFILE)
    message(WARNING "Using conanfile is still experimental.\n Manually edit this file if linking fails")
    include(conan-modules/conan.cmake)
    conan_cmake_run(CONANFILE conan-modules/conanfile.txt
            BASIC_SETUP CMAKE_TARGETS
            BUILD missing)
    target_link_libraries(${PROJECT_NAME} PRIVATE ${CONAN_TARGETS})
endif()



### Fetch or find enabled dependencies
if (ENABLE_SPDLOG)
    include(cmake-modules/Fetch_spdlog.cmake)
endif()
if (ENABLE_EIGEN3)
    include(cmake-modules/Fetch_Eigen3.cmake)
endif()
if (ENABLE_H5PP)
    include(cmake-modules/Fetch_h5pp.cmake)
endif()



### Apply all settings to current project
target_link_libraries(${PROJECT_NAME} PUBLIC project-settings)


### Link all generated targets to this project
if (TARGET Eigen3::Eigen AND ENABLE_EIGEN3)
    target_link_libraries(${PROJECT_NAME} PRIVATE Eigen3::Eigen)
endif()
if (TARGET spdlog::spdlog AND ENABLE_SPDLOG)
    target_link_libraries(${PROJECT_NAME} PRIVATE spdlog::spdlog)
endif()

if (TARGET h5pp::h5pp)
    target_link_libraries(${PROJECT_NAME} PRIVATE h5pp::h5pp h5pp::deps h5pp::flags)
endif()


### Print summary of CMake configuration
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





### CTest testing
if(ENABLE_TESTS AND NOT AS_SUBPROJECT)
    enable_testing()
    if(ENABLE_H5PP)
        add_subdirectory(tests/h5pp)
    endif()
    if(ENABLE_SPDLOG OR ENABLE_H5PP)
        add_subdirectory(tests/spdlog)
    endif()
    if(ENABLE_EIGEN3 OR ENABLE_H5PP)
        add_subdirectory(tests/eigen3)
    endif()
    if(ENABLE_OPENMP)
        add_subdirectory(tests/openmp)
    endif()
endif()







### Print general information about next steps
message("")
message("=============================================================================")
message("")
message("      To clean cmake files, run './build.sh --clear-cmake'")
message("      To clean downloaded libraries, run './build.sh --clear-libs=all '")
message("      For more info, run ./build.sh --help '")
message("")
message("=============================================================================")
message("")


