cmake_minimum_required(VERSION 3.14)
include(FetchContent)
FetchContent_Declare(fetch-fmt
        URL         https://github.com/fmtlib/fmt/archive/7.1.3.tar.gz
        URL_MD5     2522ec65070c0bda0ca288677ded2831 # 7.1.3
        CMAKE_ARGS
        -DFMT_TEST:BOOL=OFF
        -DFMT_DOC:BOOL=OFF
        )
FetchContent_MakeAvailable(fetch-fmt)