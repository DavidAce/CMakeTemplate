#!/bin/bash
PROGNAME=$0

usage() {
  cat << EOF >&2
Usage            : $PROGNAME [-option | --option ] <=argument>

-a | --arch [=arg]              : Choose microarchitecture | core2 | nehalem | sandybridge | haswell | native | (default = native)
-b | --build-type [=arg]        : Build type: [ Release | RelWithDebInfo | Debug | Profile ]  (default = Release)
-c | --clear-cmake              : Clear CMake files before build (delete ./build)
-d | --dry-run                  : Dry run
   | --download-missing         : Download missing libraries [ ON | OFF ] (default = OFF)
-f | --extra-flags [=arg]       : Extra CMake flags (defailt = none)
-g | --gcc-toolchain [=arg]     : Path to GCC toolchain. Use with Clang if it can't find stdlib (defailt = none)
-h | --help                     : Help. Shows this text.
-j | --make-threads [=num]      : Number of threads used by Make build (default = 8)
-l | --clear-libs [=args]       : Clear libraries in comma separated list 'lib1,lib2...'. "all" deletes all.
-s | --enable-shared            : Enable shared library linking (default is static)
   | --with-openmp              : Enable OpenMP
   | --with-spdlog              : Enable Spdlog logging library
   | --with-eigen3              : Enable Eigen3 linear algebra library
   | --with-h5pp                : Enable h5pp, an HDF5 wrapper for C++
-t | --build-target [=args]     : Select build target [ CMakeTemplate | all-tests | test-<name> ]  (default = none)
   | --enable-tests             : Enable CTest tests
EXAMPLE:
./build.sh --arch native -b Release  --make-threads 8   --enable-shared  --with-openmp --with-eigen3  --download-missing
EOF
  exit 1
}


# Execute getopt on the arguments passed to this program, identified by the special character $@
PARSED_OPTIONS=$(getopt -n "$0"   -o ha:b:cl:df:g:j:st: \
                --long "\
                help\
                arch:\
                build-type:\
                build-target:\
                clear-cmake\
                clear-libs:\
                dry-run\
                enable-tests\
                enable-shared\
                gcc-toolchain:\
                make-threads:\
                with-openmp\
                with-spdlog\
                with-eigen3\
                with-h5pp\
                download-missing\
                extra-flags:\
                "  -- "$@")

#Bad arguments, something has gone wrong with the getopt command.
if [ $? -ne 0 ]; then exit 1 ; fi

# A little magic, necessary when using getopt.
eval set -- "$PARSED_OPTIONS"

build_type="Release"
march=""
shared="OFF"
download_missing="OFF"
enable_tests="OFF"
enable_tests_post_build="OFF"
build_target="all"
make_threads=8
# Now goes through all the options with a case and using shift to analyse 1 argument at a time.
#$1 identifies the first argument, and when we use shift we discard the first argument, so $2 becomes $1 and goes again through the case.
echo "Build Configuration"
while true;
do
  case "$1" in
    -h|--help)                      usage                                                                       ; shift   ;;
    -a|--arch)                      march=$2                        ; echo " * Architecture             : $2"      ; shift 2 ;;
    -b|--build-type)                build_type=$2                   ; echo " * Build type               : $2"      ; shift 2 ;;
    -c|--clear-cmake)               clear_cmake="ON"                ; echo " * Clear CMake              : ON"      ; shift   ;;
    -l|--clear-libs)
            clear_libs=($(echo "$2" | tr ',' ' '))                  ; echo " * Clear libraries          : $2"      ; shift 2 ;;
    -d|--dry-run)                   dryrun="ON"                     ; echo " * Dry run                  : ON"      ; shift   ;;
    -f|--extra-flags)               extra_flags=$2                  ; echo " * Extra CMake flags        : $2"      ; shift 2 ;;
    -g|--gcc-toolchain)             gcc_toolchain=$2                ; echo " * GCC toolchain            : $2"      ; shift 2 ;;
    -j|--make-threads)              make_threads=$2                 ; echo " * MAKE threads             : $2"      ; shift 2 ;;
    -s|--enable-shared)             shared="ON"                     ; echo " * Link shared libraries    : ON"      ; shift   ;;
       --enable-tests)              enable_tests="ON"               ; echo " * CTest Testing            : ON"      ; shift   ;;
    -t|--build-target)              build_target=$2                 ; echo " * Build target             : $2"      ; shift 2 ;;
       --download-missing)          download_missing="ON"           ; echo " * Download missing libs    : ON"      ; shift   ;;
       --with-openmp)               with_openmp="ON"                ; echo " * With OpenMP              : ON"      ; shift   ;;
       --with-spdlog)               with_spdlog="ON"                ; echo " * With Spdlog              : ON"      ; shift   ;;
       --with-eigen3)               with_eigen3="ON"                ; echo " * With Eigen3              : ON"      ; shift   ;;
       --with-h5pp)                 with_h5pp="ON"                  ; echo " * With h5pp                : ON"      ; shift   ;;
    --) shift; echo ""; break;;
  esac
done




if [ -n "$clear_cmake" ] ; then
    echo "Clearing CMake files from build."
	rm -rf ./build/*
fi


for lib in "${clear_libs[@]}"; do
    if [[ "$lib" == "all" ]]; then
        echo "Clearing all installed libraries"
        rm -r ./libs/* ./cmake-build-libs/*
    else
        echo "Clearing library: $lib"
        rm -r ./libs/$lib ./cmake-build-libs/$lib
    fi
done








if [ -n "$dryrun" ]; then
    echo "Dry run build sequence"
else
    echo "Running build sequence"
fi


cat << EOF >&2
Running script:
===============================================================
    cmake -E make_directory build/$build_type
    cd build/$build_type
    cmake   -DCMAKE_BUILD_TYPE=$build_type
            -DMARCH=$march
            -DENABLE_OPENMP=$with_openmp
            -DENABLE_SPDLOG=$with_spdlog
            -DENABLE_H5PP=$with_h5pp
            -DENABLE_TESTS=$enable_tests
            -DDOWNLOAD_MISSING=$download_missing
            -DBUILD_SHARED_LIBS=$shared
            -DGCC_TOOLCHAIN=$gcc_toolchain
            $extra_flags
            -G "CodeBlocks - Unix Makefiles" ../../
    cmake --build . --target $build_target -- -j $make_threads
===============================================================
EOF


if [ -z "$dryrun" ] ;then
    cmake -E make_directory build/$build_type
    cd build/$build_type
    cmake   -DCMAKE_BUILD_TYPE=$build_type \
            -DMARCH=$march \
            -DENABLE_OPENMP=$with_openmp \
            -DENABLE_SPDLOG=$with_spdlog \
            -DENABLE_EIGEN3=$with_eigen3\
            -DENABLE_H5PP=$with_h5pp\
            -DENABLE_TESTS=$enable_tests \
            -DDOWNLOAD_MISSING=$download_missing \
            -DBUILD_SHARED_LIBS=$shared \
            -DGCC_TOOLCHAIN=$gcc_toolchain \
            $extra_flags \
            -G "CodeBlocks - Unix Makefiles" ../../
    cmake --build . --target $build_target -- -j $make_threads
fi

