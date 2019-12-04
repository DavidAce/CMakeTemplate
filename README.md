[![Build Status](https://travis-ci.org/DavidAce/CMakeTemplate.svg?branch=cpp-cmake)](https://travis-ci.org/DavidAce/CMakeTemplate)
# CMake Template
A template for building C++ projects using **modern** CMake with automated (but optional) software packages.


This template has two main purposes. 
1) To speed up the process of deploying a new C++ project with a selection of 
optional libraries that.
2) Serve as a base for learning CMake. I believe that automating dependencies as shown here is a good way to showcase many aspects of CMake.
 
The optional packages are:
- [Eigen3](http://eigen.tuxfamily.org/)  For linear algebra
- [spdlog](https://github.com/gabime/spdlog) For logging
- [h5pp](https://github.com/DavidAce/h5pp) For fast and simple binary storage

The reasoning behind this selection is that these libraries are either useful (to me), a staple in scientific computing 
or simple enough to install and link to. 

## Features
- Optional software components (see below) installed locally at configure-time
- Unit testing with CTest 
- Travis-CI testing
- Convenience shell script for building and selecting software components

## Compatibility
This template has only been tested in Linux environments.


## Requirements

- C++ compiler. Tested with
    - GNU GCC version >= 8,
    - LLVM Clang version >= 7
    - **Note that h5pp requires C++17**
- CMake version 3.12 or above.


## Usage
Build as any regular out-of-source CMake project.

To make it even simpler you can use the supplied build script `./build.sh`.

Example:

    git clone https://github.com/DavidAce/CMakeTemplate.git
    cd CMakeTemplate
    ./build.sh --enable-openmp --with-eigen3 --download-missing

Type `./build.sh -h` to see how to enable/disable more options.


## CMake build options
- Enable Eigen3 linear algebra library         `-D ENABLE_EIGEN3:BOOL=ON/OFF`        (default `OFF`)
- Enable spdlog logging library                `-D ENABLE_SPDLOG:BOOL=ON/OFF`        (default `OFF`)
- Enable h5pp HDF5-wrapper library for C++     `-D ENABLE_H5PP:BOOL=ON/OFF`          (default `OFF`)
    - Note: h5pp includes HDF5, Eigen3 and spdlog 
- Download missing libraries                   `-D DOWNLOAD_MISSING:BOOL=ON/OFF`     (default `OFF`)
- Enable testing (ctest)                       `-D ENABLE_TESTS:BOOL=ON/OFF`         (default `OFF`)
- Enable testing directly after build          `-D ENABLE_TESTS_POST_BUILD:BOOL=ON/OFF`         (default `OFF`)
- Enable OpenMP                                `-D ENABLE_OPENMP:BOOL=ON/OFF`        (default `OFF`)
- Shared/static linking                        `-D BUILD_SHARED_LIBS:BOOL=ON/OFF`    (default `OFF`)
- Compile architecture                         `-D MARCH=<arch>`                     (default `native`)
- Path to gnu toolchain for use with Clang     `-D GCC_TOOLCHAIN:PATH=...`           (default `none`)

