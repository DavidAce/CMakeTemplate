

# This makes sure we use our modules to find dependencies!
list(INSERT CMAKE_MODULE_PATH 0 ${PROJECT_SOURCE_DIR}/cmake)


if(ENABLE_OPENMP)
    find_package(OpenMP REQUIRED) # Uses a custom find module
    ##############################################################################
    ###  Optional OpenMP support                                               ###
    ###  Note that Clang has some  trouble with static openmp and that         ###
    ###  and that static openmp is not recommended. This tries to enable       ###
    ###  static openmp anyway because I find it useful. Installing             ###
    ###  libiomp5 might help for shared linking.                               ###
    ##############################################################################
    if(TARGET openmp::openmp)
        target_link_libraries(project-settings INTERFACE openmp::openmp)
    else()
        target_compile_options(project-settings INTERFACE -Wno-unknown-pragmas)
    endif()
endif()



##################################################################
### Install conan-modules/conanfile.txt dependencies          ###
### This uses conan to get spdlog/eigen3/h5pp/ceres           ###
###    h5pp/1.5.1@davidace/stable                             ###
###    eigen/3.3.7@conan/stable                               ###
###    spdlog/1.4.2@bincrafters/stable                        ###
##################################################################


find_program (
        CONAN_COMMAND
        conan
        HINTS ${CONAN_PREFIX} ${CONDA_PREFIX} $ENV{CONAN_PREFIX} $ENV{CONDA_PREFIX}
        PATHS $ENV{HOME}/anaconda3 $ENV{HOME}/miniconda $ENV{HOME}/.conda
        PATH_SUFFIXES bin envs/dmrg/bin envs/bin
)


# Download automatically, you can also just copy the conan.cmake file
if(NOT EXISTS "${CMAKE_BINARY_DIR}/conan.cmake")
    message(STATUS "Downloading conan.cmake from https://github.com/conan-io/cmake-conan")
    file(DOWNLOAD "https://github.com/conan-io/cmake-conan/raw/v0.14/conan.cmake"
            "${CMAKE_BINARY_DIR}/conan.cmake")
endif()

include(${CMAKE_BINARY_DIR}/conan.cmake)

if(CMAKE_CXX_COMPILER_ID MATCHES "AppleClang")
    # Let it autodetect libcxx
elseif(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
    # There is no libcxx
elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    list(APPEND conan_libcxx compiler.libcxx=libstdc++11)
endif()


if(ENABLE_EIGEN3 AND ENABLE_SPDLOG AND EXISTS ${PROJECT_SOURCE_DIR}/conanfile.txt)
conan_cmake_run(CONANFILE conanfile.txt
        CONAN_COMMAND ${CONAN_COMMAND}
        SETTINGS compiler.cppstd=17
        SETTINGS "${conan_libcxx}"
        BUILD_TYPE ${CMAKE_BUILD_TYPE}
        BASIC_SETUP CMAKE_TARGETS
        BUILD missing)
else()
    if(ENABLE_EIGEN3)
        set(SINGLE_CONAN_PACKAGE_EIGEN3 eigen/3.3.7@conan/stable)
    endif()
    if(ENABLE_SPDLOG)
        set(SINGLE_CONAN_PACKAGE_SPDLOG  spdlog/1.4.2@bincrafters/stable)
    endif()
    if(ENABLE_H5PP)
        set(SINGLE_CONAN_PACKAGE_H5PP h5pp/1.5.1@davidace/stable)
    endif()

    conan_cmake_run(
            CONAN_COMMAND ${CONAN_COMMAND}
            SETTINGS compiler.cppstd=17
            SETTINGS "${conan_libcxx}"
            BUILD_TYPE ${CMAKE_BUILD_TYPE}
            REQUIRES ${SINGLE_CONAN_PACKAGE_H5PP}
            REQUIRES ${SINGLE_CONAN_PACKAGE_EIGEN3}
            REQUIRES ${SINGLE_CONAN_PACKAGE_SPDLOG}
            BASIC_SETUP CMAKE_TARGETS
            BUILD missing)

endif()

##################################################################
### Link all the things!                                       ###
##################################################################
message("CONAN TARGETS: ${CONAN_TARGETS}")
target_link_libraries(project-settings INTERFACE ${CONAN_TARGETS})





