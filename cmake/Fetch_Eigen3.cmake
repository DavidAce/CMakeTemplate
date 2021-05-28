cmake_minimum_required(VERSION 3.14)
include(FetchContent)
FetchContent_Declare(fetch-eigen3
        URL      https://gitlab.com/libeigen/eigen/-/archive/3.3.9/eigen-3.3.9.tar.gz
        URL_MD5  609286804b0f79be622ccf7f9ff2b660
        QUIET
        CMAKE_ARGS
        -DEIGEN_TEST_CXX11:BOOL=OFF
        -DBUILD_TESTING:BOOL=OFF
        )
#FetchContent_MakeAvailable(fetch-Eigen3) // Avoid needless configure on header only library

FetchContent_GetProperties(fetch-eigen3)
if(NOT fetch-eigen3_POPULATED)
    # Fetch the content using previously declared details
    FetchContent_Populate(fetch-eigen3)
    find_package(Eigen3 REQUIRED HINTS ${fetch-eigen3_BINARY_DIR} NO_DEFAULT_PATH)
endif()

