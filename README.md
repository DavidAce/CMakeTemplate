[![Build Status](https://travis-ci.org/DavidAce/CMakeTemplates.svg?branch=cpp-cmake)](https://travis-ci.org/DavidAce/CMakeTemplates)
# CMake Templates
A collecion of templates for building C++17 projects  using **modern** CMake. 

Different templates can be found in the branches of this repository.

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


## Common options on all templates
- Enable/disable OpenMP `-D ENABLE_OPENMP:BOOL=ON/OFF`     (default `OFF`)
- spdlog logging library `-D ENABLE_SPDLOG:BOOL=ON/OFF`    (default `ON`)
- Shared/static linking `-D BUILD_SHARED_LIBS:BOOL=ON/OFF` (default `OFF`)
- Compile architecture `-D MARCH=<arch>`  (default `<arch>=native`)
- Automatic download of external libraries `-D DOWNLOAD_LIBS:BOOL=ON/OFF` (default `ON`)
- Unit testing `-D ENABLE_TESTS:BOOL=ON/OFF` (default `ON`)

## Branches
- cpp-cmake
- ...more to come


## cpp-cmake
This is a minimal template with nothing more than all the common options listed above.

