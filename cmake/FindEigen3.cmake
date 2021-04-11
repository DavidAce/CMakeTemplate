# This sets the following variables

# EIGEN3_INCLUDE_DIR
# EIGEN3_VERSION
# Eigen3_FOUND

# as well as a target Eigen3::Eigen
#
# To guide the find behavior the user can set the following variables to TRUE/FALSE:

# EIGEN3_NO_CMAKE_PACKAGE_REGISTRY
# EIGEN3_NO_DEFAULT_PATH
# EIGEN3_NO_CONFIG
# EIGEN3_CONFIG_ONLY

# As well as search directory hints from CMake or environment, such as
# Eigen3_ROOT
# Eigen3_DIR
# EIGEN3_INCLUDE_DIR

if(NOT Eigen3_FIND_VERSION)
    if(NOT Eigen3_FIND_VERSION_MAJOR)
        set(Eigen3_FIND_VERSION_MAJOR 2)
    endif()
    if(NOT Eigen3_FIND_VERSION_MINOR)
        set(Eigen3_FIND_VERSION_MINOR 91)
    endif()
    if(NOT Eigen3_FIND_VERSION_PATCH)
        set(Eigen3_FIND_VERSION_PATCH 0)
    endif()
    set(Eigen3_FIND_VERSION "${Eigen3_FIND_VERSION_MAJOR}.${Eigen3_FIND_VERSION_MINOR}.${Eigen3_FIND_VERSION_PATCH}")
endif()

macro(_eigen3_check_version)
    if(EXISTS ${EIGEN3_INCLUDE_DIR}/Eigen/src/Core/util/Macros.h)
        file(READ "${EIGEN3_INCLUDE_DIR}/Eigen/src/Core/util/Macros.h" _eigen3_version_header)
        string(REGEX MATCH "define[ \t]+EIGEN_WORLD_VERSION[ \t]+([0-9]+)" _eigen3_world_version_match "${_eigen3_version_header}")
        set(EIGEN3_WORLD_VERSION "${CMAKE_MATCH_1}")
        string(REGEX MATCH "define[ \t]+EIGEN_MAJOR_VERSION[ \t]+([0-9]+)" _eigen3_major_version_match "${_eigen3_version_header}")
        set(EIGEN3_MAJOR_VERSION "${CMAKE_MATCH_1}")
        string(REGEX MATCH "define[ \t]+EIGEN_MINOR_VERSION[ \t]+([0-9]+)" _eigen3_minor_version_match "${_eigen3_version_header}")
        set(EIGEN3_MINOR_VERSION "${CMAKE_MATCH_1}")

        set(EIGEN3_VERSION ${EIGEN3_WORLD_VERSION}.${EIGEN3_MAJOR_VERSION}.${EIGEN3_MINOR_VERSION})
        if(${EIGEN3_VERSION} VERSION_LESS ${Eigen3_FIND_VERSION})
            set(EIGEN3_VERSION_OK FALSE)
        else()
            set(EIGEN3_VERSION_OK TRUE)
        endif()
        if(NOT EIGEN3_VERSION_OK)
            message(STATUS "Eigen3 version ${EIGEN3_VERSION} found in ${EIGEN3_INCLUDE_DIR}, "
                    "but at least version ${Eigen3_FIND_VERSION} is required")
        endif()
    else()
        set(EIGEN3_VERSION_OK FALSE)
    endif()

endmacro()


# First we check if the EIGEN3_INCLUDE_DIR path is in the cache
# We may already have run this script

if (TARGET Eigen3::Eigen AND EIGEN3_INCLUDE_DIR)
    # in cache already
    _eigen3_check_version()
    set(Eigen3_FOUND ${EIGEN3_VERSION_OK})
endif()


if(NOT Eigen3_FOUND)
    if(EIGEN3_NO_DEFAULT_PATH OR Eigen3_NO_DEFAULT_PATH)
        set(NO_DEFAULT_PATH NO_DEFAULT_PATH)
    endif()
    if(EIGEN3_NO_CMAKE_PACKAGE_REGISTRY OR Eigen3_NO_CMAKE_PACKAGE_REGISTRY)
        set(NO_CMAKE_PACKAGE_REGISTRY NO_CMAKE_PACKAGE_REGISTRY)
    endif()


    if(NOT EIGEN3_NO_CONFIG OR EIGEN3_CONFIG_ONLY)
        find_package(Eigen3 ${Eigen3_FIND_VERSION}
                HINTS ${Eigen3_ROOT} ${CONAN_EIGEN3_ROOT} ${CMAKE_INSTALL_PREFIX}
                PATHS ${CMT_CONDA_CANDIDATE_PATHS}
                PATH_SUFFIXES share/eigen3/cmake include Eigen3 eigen3 include/Eigen3 include/eigen3 Eigen3/include/eigen3
                ${NO_DEFAULT_PATH}
                ${NO_CMAKE_PACKAGE_REGISTRY}
                CONFIG QUIET)
    endif()
    if (TARGET Eigen3::Eigen)
        if(NOT EIGEN3_INCLUDE_DIR)
            get_target_property(EIGEN3_INCLUDE_DIR Eigen3::Eigen INTERFACE_INCLUDE_DIRECTORIES)
        endif()
        if(NOT EIGEN3_INCLUDE_DIR)
            get_target_property(EIGEN3_INCLUDE_DIR Eigen3::Eigen INTERFACE_SYSTEM_INCLUDE_DIRECTORIES)
        endif()
        _eigen3_check_version()
        if(EIGEN3_VERSION_OK)
            set(Eigen3_FOUND ${EIGEN3_VERSION_OK})
            target_include_directories(Eigen3::Eigen SYSTEM INTERFACE ${EIGEN3_INCLUDE_DIR})
        endif()
    endif()


    if(NOT TARGET Eigen3::Eigen OR NOT EIGEN3_INCLUDE_DIR AND NOT EIGEN3_CONFIG_ONLY)
        # If no config was found, try finding Eigen in a similar way as the original FindEigen3.cmake does it
        # This way we can avoid supplying the original file and allow more flexibility for overriding

        find_path(EIGEN3_INCLUDE_DIR NAMES signature_of_eigen3_matrix_library
                HINTS ${Eigen3_ROOT} ${CONAN_EIGEN3_ROOT} ${CMAKE_INSTALL_PREFIX}
                PATHS ${CMT_CONDA_CANDIDATE_PATHS} ${KDE4_INCLUDE_DIR}
                PATH_SUFFIXES include/eigen3 Eigen3 eigen3 include/Eigen3 Eigen3/include/eigen3
                ${NO_DEFAULT_PATH}
                ${NO_CMAKE_PACKAGE_REGISTRY}
                )
        if(EIGEN3_INCLUDE_DIR)
            _eigen3_check_version()
        endif()
    endif()
endif()

if(NOT TARGET Eigen3::Eigen AND EIGEN3_INCLUDE_DIR AND EIGEN3_VERSION_OK)
    add_library(Eigen3::Eigen INTERFACE IMPORTED)
    target_include_directories(Eigen3::Eigen SYSTEM INTERFACE ${EIGEN3_INCLUDE_DIR})
endif()


# Compatibility with config
set(EIGEN3_INCLUDE_DIRS ${EIGEN3_INCLUDE_DIR})
set(EIGEN3_VERSION_STRING ${EIGEN3_VERSION})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Eigen3
        FOUND_VAR Eigen3_FOUND
        REQUIRED_VARS EIGEN3_INCLUDE_DIR EIGEN3_VERSION_OK
        VERSION_VAR EIGEN3_VERSION
        FAIL_MESSAGE "Failed to find Eigen3"
        )
