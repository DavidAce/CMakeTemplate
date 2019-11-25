[![Build Status](https://travis-ci.org/DavidAce/CMakeTemplate.svg?branch=cpp-cmake)](https://travis-ci.org/DavidAce/CMakeTemplate)
# CMake Template
A template for building C++17 projects using **modern** CMake with optional software packages. 


## Features
- Optional software components (see below) installed locally at configure-time
- Unit testing with CTest 
- Travis-CI testing
- Convenience shell script for building and selecting software components


## Requirements
- C++ compiler with C++17 support. Tested with
    - GNU GCC version >= 8,
    - LLVM Clang version >= 7
- CMake version 3.10 or above.


## Usage
Build as any regular out-of-source CMake project.

To make it even simpler you can use the supplied build script `./build.sh`.

For instance, to build the branch `cpp-cmake` simply run these lines at the command-line:

    git clone https://github.com/DavidAce/CMakeTemplate.git
    cd CMakeTemplate
    ./build.sh

Type `./build.sh -h` to see how to enable/disable more options.


## CMake build options
- Enable Eigen3 linear algebra library         `-D ENABLE_EIGEN3:BOOL=ON/OFF`        (default `OFF`)
- Enable spdlog logging library                `-D ENABLE_SPDLOG:BOOL=ON/OFF`        (default `OFF`)
- Enable h5pp HDF5-wrapper library for C++     `-D ENABLE_H5PP:BOOL=ON/OFF`          (default `OFF`)
    - Note: h5pp includes HDF5, Eigen3 and spdlog 
- Download missing libraries                   `-D DOWNLOAD_MISSING:BOOL=ON/OFF`        (default `OFF`)
- Disable testing (ctest)                      `-D DISABLE_TESTING:BOOL=ON/OFF`      (default `OFF`)
- Enable OpenMP                                `-D ENABLE_OPENMP:BOOL=ON/OFF`        (default `OFF`)
- Shared/static linking                        `-D BUILD_SHARED_LIBS:BOOL=ON/OFF`    (default `OFF`)
- Compile architecture                         `-D MARCH=<arch>`                     (default `native`)
- Path to gnu toolchain for use with Clang     `-D GCC_TOOLCHAIN:PATH=...`           (default `none`)

