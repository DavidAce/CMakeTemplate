#!/bin/bash
PROGNAME=$0

usage() {
  cat << EOF >&2
Usage            : $PROGNAME [-option | --option ] <=argument>

-a | --arch [=arg]              : Choose microarchitecture | core2 | nehalem | sandybridge | haswell | native | (default = native)
-b | --build-type [=arg]        : Build type: [ Release | RelWithDebInfo | Debug | Profile ]  (default = Release)
-c | --clear-cmake              : Clear CMake files before build (delete ./build)
-d | --dry-run                  : Dry run
   | --download-method          : Download libraries using [ native | conan ] (default = native)
-f | --extra-flags [=arg]       : Extra CMake flags (defailt = none)
-g | --gcc-toolchain [=arg]     : Path to GCC toolchain. Use with Clang if it can't find stdlib (defailt = none)
-h | --help                     : Help. Shows this text.
-j | --make-threads [=num]      : Number of threads used by Make build (default = 8)
-l | --clear-libs [=args]       : Clear libraries in comma separated list 'lib1,lib2...'. "all" deletes all.
-s | --enable-shared            : Enable shared library linking (default is static)
   | --enable-openmp            : Enable OpenMP
   | --enable-spdlog            : Enable Spdlog logging library
   | --enable-eigen3            : Enable Eigen3 linear algebra library
   | --enable-h5pp              : Enable h5pp, an HDF5 wrapper for C++
-t | --target [=args]           : Select CMake build target [ CMakeTemplate | test-<name> ]  (default = none)
   | --enable-tests             : Enable CTest tests
-v | --verbose                  : Verbose makefiles
EXAMPLE:
./build.sh -b Release  --make-threads 8   --enable-shared  --enable-openmp --enable-eigen3  --download-method=native
EOF
  exit 1
}


# Execute getopt on the arguments passed to this program, identified by the special character $@
PARSED_OPTIONS=$(getopt -n "$0"   -o hb:cl:df:g:j:st:v \
                --long "\
                help\
                build-type:\
                target:\
                clear-cmake\
                clear-libs:\
                dry-run\
                download-method:\
                enable-tests\
                enable-shared\
                gcc-toolchain:\
                make-threads:\
                enable-openmp\
                enable-spdlog\
                enable-eigen3\
                enable-h5pp\
                extra-flags:\
                verbose\
                "  -- "$@")

#Bad arguments, something has gone wrong with the getopt command.
if [ $? -ne 0 ]; then exit 1 ; fi

# A little magic, necessary when using getopt.
eval set -- "$PARSED_OPTIONS"

build_type="Release"
shared="OFF"
download_method="native"
enable_tests="OFF"
target="all"
make_threads=8
verbose="OFF"
# Now goes through all the options with a case and using shift to analyse 1 argument at a time.
#$1 identifies the first argument, and when we use shift we discard the first argument, so $2 becomes $1 and goes again through the case.
echo "Build Configuration"
while true;
do
  case "$1" in
    -h|--help)                      usage                                                                       ; shift   ;;
    -b|--build-type)                build_type=$2                   ; echo " * Build type               : $2"      ; shift 2 ;;
    -c|--clear-cmake)               clear_cmake="ON"                ; echo " * Clear CMake              : ON"      ; shift   ;;
    -l|--clear-libs)
            clear_libs=($(echo "$2" | tr ',' ' '))                  ; echo " * Clear libraries          : $2"      ; shift 2 ;;
    -d|--dry-run)                   dryrun="ON"                     ; echo " * Dry run                  : ON"      ; shift   ;;
       --download-method)           download_method=$2              ; echo " * Download method          : $2"      ; shift 2 ;;
    -f|--extra-flags)               extra_flags=$2                  ; echo " * Extra CMake flags        : $2"      ; shift 2 ;;
    -g|--gcc-toolchain)             gcc_toolchain=$2                ; echo " * GCC toolchain            : $2"      ; shift 2 ;;
    -j|--make-threads)              make_threads=$2                 ; echo " * MAKE threads             : $2"      ; shift 2 ;;
    -s|--enable-shared)             shared="ON"                     ; echo " * Link shared libraries    : ON"      ; shift   ;;
       --enable-tests)              enable_tests="ON"               ; echo " * CTest Testing            : ON"      ; shift   ;;
    -t|--target)                    target=$2                       ; echo " * CMake build target       : $2"      ; shift 2 ;;
       --enable-openmp)             enable_openmp="ON"              ; echo " * Enable OpenMP            : ON"      ; shift   ;;
       --enable-spdlog)             enable_spdlog="ON"              ; echo " * Enable Spdlog            : ON"      ; shift   ;;
       --enable-eigen3)             enable_eigen3="ON"              ; echo " * Enable Eigen3            : ON"      ; shift   ;;
       --enable-h5pp)               enable_h5pp="ON"                ; echo " * Enable h5pp              : ON"      ; shift   ;;
    -v|--verbose)                   verbose="ON"                    ; echo " * Verbose makefiles        : ON"      ; shift   ;;
    --) shift; echo ""; break;;
  esac
done




if  [ -n "$clear_cmake" ] ; then
    echo "Clearing CMake files from build."
	rm -rf ./build/$build_type
fi

build_type_lower=$(echo $build_type | tr '[:upper:]' '[:lower:]')
for lib in "${clear_libs[@]}"; do
    if [[ "$lib" == "all" ]]; then
        echo "Clearing all installed libraries"
        rm -r ./build/$build_type/deps-build/*
        rm -r ./build/$build_type/deps-install/*
    else
        echo "Clearing library: $lib"
        rm -r ./build/$build_type/deps-build/$lib
        rm -r ./build/$build_type/deps-install/$lib
    fi
done

if [[ ! "$download_method" =~ native|conan|find|none ]]; then
    echo "Download method unsupported: $download_method"
    exit 1
fi



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
            -DDOWNLOAD_METHOD=$download_method
            -DENABLE_OPENMP=$enable_openmp
            -DENABLE_SPDLOG=$enable_spdlog
            -DENABLE_H5PP=$enable_h5pp
            -DENABLE_TESTS=$enable_tests
            -DBUILD_SHARED_LIBS=$shared
            -DGCC_TOOLCHAIN=$gcc_toolchain
            -DCMAKE_VERBOSE_MAKEFILE=$verbose
            $extra_flags
            -G "CodeBlocks - Unix Makefiles" ../../
    cmake --build . --target $target -- -j $make_threads
===============================================================
EOF


if [ -z "$dryrun" ] ;then
    cmake -E make_directory build/$build_type
    cd build/$build_type
    cmake   -DCMAKE_BUILD_TYPE=$build_type \
            -DDOWNLOAD_METHOD=$download_method \
            -DENABLE_OPENMP=$enable_openmp \
            -DENABLE_SPDLOG=$enable_spdlog \
            -DENABLE_EIGEN3=$enable_eigen3 \
            -DENABLE_H5PP=$enable_h5pp \
            -DENABLE_TESTS=$enable_tests \
            -DBUILD_SHARED_LIBS=$shared \
            -DGCC_TOOLCHAIN=$gcc_toolchain \
            -DCMAKE_VERBOSE_MAKEFILE=$verbose \
            $extra_flags \
            -G "CodeBlocks - Unix Makefiles" ../../
    cmake --build . --target $target -- -j $make_threads
fi

if [ "$enable_tests" = "ON" ] ;then
    if [[ "$target" == *"test-"* ]]; then
        ctest -C $build_type --verbose -R $target
    else
       ctest -C $build_type --output-on-failure
    fi
fi