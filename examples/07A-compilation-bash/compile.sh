#!/bin/bash

args=(
    # Include directories
    -isystem /home/david/.conan2/p/pcg-c4aa2cafcf36e3/p/include           #include <CLI/CLI.hpp>
    -isystem /home/david/.conan2/p/cli11387b72d23d771/p/include           #include <pcg_random.hpp>
    -isystem /home/david/.conan2/p/b/fmt82e3347fcfd84/p/include           #include <fmt/core.h>
    -isystem /home/david/.conan2/p/b/spdlo263bd7b74803d/p/include         #include <spdlog/spdlog.h>
    -isystem /home/david/.conan2/p/eigen3d88c0279cc26/p/include/eigen3    #include <Eigen/Core>

    # Compilation flags
    -std=c++20                                                            # the language standard
    -fopenmp                                                              # Use OpenMP
    -O3 -DNDEBUG -march=native -mtune=native                              # optimization flags
    -DH5PP_USE_EIGEN3 -DH5PP_USE_FMT -DH5PP_USE_SPDLOG                    # Preprocessor definitions for eigen and h5pp
    -DSPDLOG_COMPILED_LIB -DSPDLOG_FMT_EXTERNAL                           # Preprocessor definitions for spdlog

    #Compilation units
    source/cli.cpp                                                        # compile this file
    source/rnd.cpp                                                        # compile this file
    source/main.cpp                                                       # compile this file

    # Link Libraries
    /home/david/.conan2/p/b/hdf52c0dc284e4048/p/lib/libhdf5_hl_cpp.a      # Link HDF5 high level c++ library
    /home/david/.conan2/p/b/hdf52c0dc284e4048/p/lib/libhdf5_hl.a          # Link HDF5 high level c library
    /home/david/.conan2/p/b/hdf52c0dc284e4048/p/lib/libhdf5_cpp.a         # Link HDF5 c++ library
    /home/david/.conan2/p/b/hdf52c0dc284e4048/p/lib/libhdf5.a             # Link HDF5 c library
    /home/david/.conan2/p/b/zlibf9cdec23d5343/p/lib/libz.a                # Link gnu zip compression library
    /home/david/.conan2/p/b/spdlo263bd7b74803d/p/lib/libspdlog.a          # Link spdlog library
    /home/david/.conan2/p/b/fmt82e3347fcfd84/p/lib/libfmt.a               # Link fmt library
    -ldl                                                                  # Link dynamic loader
    -lm                                                                   # Standard Math library

    # Executable
    -o example07A                                                         # output executable name
)


g++ "${args[@]}"
