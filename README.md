[![Build Status](https://travis-ci.org/DavidAce/CMakeTemplates.svg?branch=cpp-cmake)](https://travis-ci.org/DavidAce/CMakeTemplates)
# CMake Templates
A collecion of templates for building C++17 projects using **modern** CMake. 


## Features
All these templates have a basic set of features in common:

- Unit testing of enabled features
- travis-ci testing for multiple compiler configurations
- convenience shell script for building and setting options
- Supports build modes Release/Debug
- (optional) Automatic download and linking to [spdlog](https://github.com/gabime/spdlog)  logginglibrary 
- (optional) Correctly sets flag for OpenMP (gcc/clang and static/dynamic build)


## Branches
- cpp-cmake
- ...more to come

## Requirements
- C++ compiler with C++17 support
- CMake version 3.10 or above.

## Usage
Build as any regular out-of-source CMake project.

To make it even simpler you can use the supplied build script `./build.sh`.

For instance, to build the branch `cpp-cmake` simply run these lines at the command-line:

    git clone https://github.com/DavidAce/CMakeTemplates.git
    cd CMakeTemplates
    git checkout cpp-cmake
    ./build.sh

Type `./build.sh -h` to see how to enable/disable more options.


## Build options
- Enable testing (ctest) `-D ENABLE_TESTS:BOOL=ON/OFF` (default `ON`)
- Download external libraries `-D DOWNLOAD_LIBS:BOOL=ON/OFF` (default `ON`)
- spdlog logging library `-D ENABLE_SPDLOG:BOOL=ON/OFF`    (default `ON`)
- Enable/disable OpenMP `-D ENABLE_OPENMP:BOOL=ON/OFF`     (default `OFF`)
- Shared/static linking `-D BUILD_SHARED_LIBS:BOOL=ON/OFF` (default `OFF`)
- Compile architecture `-D MARCH=<arch>`  (default `<arch>=native`)
- Path to gnu toolchain for use with Clang `-D GCC_TOOLCHAIN:PATH=...`  (default `none`)




## cpp-cmake
This is a minimal template with nothing more than all the common options listed above.

