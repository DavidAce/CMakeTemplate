[![Ubuntu 22.04](https://github.com/DavidAce/CMakeTemplate/actions/workflows/ubuntu-22.04.yml/badge.svg)](https://github.com/DavidAce/CMakeTemplate/actions/workflows/ubuntu-22.04.yml)

# CMake Template
A template for building C++ projects using modern CMake with dependencies handled by Conan.

## Features
- Unit testing with CTest 
- Conan integration for dependencies

## Requirements
- C++17 compiler. Tested with
    - GNU GCC version 12,
    - LLVM Clang version 15
- CMake version 3.24 or above.
- conan version 2 **(Recommended)**

## Dependencies
By default, the direct dependencies are:
- [h5pp](https://github.com/DavidAce/h5pp) For fast and simple binary storage (includes hdf5, eigen, spdlog and fmt)
- [Eigen3](http://eigen.tuxfamily.org/)  For linear algebra
- [fmt](https://github.com/fmtlib/fmt)  For string formatting
- [spdlog](https://github.com/gabime/spdlog)  For logging

These dependencies are installed automatically when using the bundled CMake Presets `release-conan` or `debug-conan`.

Note that `h5pp` itself has the same dependencies, so they should already be present if `h5pp` was installed previously.


## Compatibility
This template has only been tested in Linux environments.


## Usage with CMake Presets
Build as any regular out-of-source CMake project after installing the dependencies above.

Use the bundled CMake Presets to opt-in to automatic dependency installation with conan.

#### Step 1: Install conan

    pip install conan
    conan profile detect

#### Step 2: Clone CMakeTemplate and list its presets
Open a terminal and run

    git clone https://github.com/DavidAce/CMakeTemplate.git
    cd CMakeTemplate
    cmake --list-presets
    -------------------------------------------------------
    >    Available configure presets:
    >
    >      "release-conan" - Release|conan package manager
    >      "debug-conan"   - Debug|conan package manager

#### Step 3: Configure and build
Select a preset listed in the previous step, and run

    cmake --preset=release-conan
    cmake --build --preset=release-conan

These commands configure the project and builds the executable at `./build/release-conan/CMT`

