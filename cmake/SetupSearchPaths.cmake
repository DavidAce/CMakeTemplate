cmake_minimum_required(VERSION 3.12)

# Make sure we can use CMT's own find modules
list(INSERT CMAKE_MODULE_PATH 0  ${PROJECT_SOURCE_DIR}/cmake)

# Some systems use lib64/ instead of lib when finding libraries
if (CMAKE_SIZEOF_VOID_P EQUAL 8 OR CMAKE_GENERATOR MATCHES "64")
    set(FIND_LIBRARY_USE_LIB64_PATHS ON)
elseif (CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(FIND_LIBRARY_USE_LIB32_PATHS ON)
endif ()

# Turn on for debugging find_package calls
set(CMAKE_FIND_DEBUG_MODE OFF)



