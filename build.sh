#!/bin/bash
PROGNAME=$0


usage() {
  cat << EOF >&2
Usage            : $PROGNAME [-option <argument>]

-a               : Choose microarchitecture | core2 | nehalem | sandybridge | haswell | native | (default = native)
-b <build type>  : Build type: [ Release | RelWithDebInfo | Debug | Profile ]  (default = Release)
-c               : Clear CMake files before build (delete ./build)
-d               : Dry run
-h               : Help. Shows this text.
-j <num_threads> : Number of threads used by CMake (default = 8)
-l <lib name>    : Clear library before build (i.e. delete ./libs/<lib name> and ./cmake-build-libs/<lib name>)
-L               : Clear all downloaded libraries before build (i.e. delete ./libs and ./cmake-build-libs)
-o <ON|OFF>      : OpenMP use      | ON | OFF | (default = OFF)
-s <ON|OFF>      : Shared libs     | ON | OFF | (default = OFF)
-t <target>      : Build target    | all | all-tests | myproject | (default = all)
-p <path>        : Path to gcc installation (default = )

EXAMPLE:
./build.sh -s OFF -a native -j 20 -o OFF  -b Release -c
EOF
  exit 1
}


target="all"
build="Release"
march="native"
omp="OFF"
shared="OFF"
make_threads=8
clear_libs=""

while getopts a:b:cdg:hj:l:Lo:p:s:t: o; do
    case $o in
	    (a) march=$OPTARG;;
        (b) build=$OPTARG;;
        (c) clear_cmake="true";;
        (d) dryrun="true";;
        (h) usage;;
        (j) make_threads=$OPTARG;;
        (l) clear_lib+=("$OPTARG");;
        (L) clear_libs="true";;
        (o) omp=$OPTARG;;
        (p) gcc_toolchain=--gcc-toolchain=$OPTARG;;
        (s) shared=$OPTARG;;
        (t) target=$OPTARG;;
        (:) echo "Option -$OPTARG requires an argument." >&2 ; exit 1 ;;
        (*) usage ;;
  esac
done


shift "$((OPTIND - 1))"


if [ -n "$clear_cmake" ] ; then
    echo "Clearing CMake files from build."
	rm -rf ./build
fi

if [ "$clear_libs" = true ] ; then
    echo "Clearing downloaded libraries."
	rm -rf ./libs ./cmake-build-libs
else
    for lib in "${clear_lib[@]}"; do
        rm -r ./libs/$lib ./cmake-build-libs/$lib
    done
fi


echo "Starting Build"
echo "CC              :   $CC"
echo "CXX             :   $CXX"
echo "Micro arch.     :   $march"
echo "Target          :   $target"
echo "Build threads   :   $make_threads"
echo "Build Type      :   $build"
echo "OpenMP          :   $omp"
echo "Shared build    :   $shared"
echo "gcc toolchain   :   $gcc_toolchain"
echo "CMake version   :   $(cmake --version) at $(which cmake)"


if [ -n "$dryrun" ]; then
    echo "Dry run build sequence"
else
    echo "Running build sequence"
fi


echo ">> cmake -E make_directory build/$build"
echo ">> cd build/$build"
echo ">> cmake -DCMAKE_BUILD_TYPE=$build -DMARCH=$march  -DENABLE_OPENMP=$omp -DBUILD_SHARED_LIBS=$shared -DGCC_TOOLCHAIN=$gcc_toolchain  -G "CodeBlocks - Unix Makefiles" ../../"
echo ">> cmake --build . --target $target -- -j $make_threads"

if [ -z "$dryrun" ] ;then
    cmake -E make_directory build/$build
    cd build/$build
    cmake -DCMAKE_BUILD_TYPE=$build -DMARCH=$march  -DENABLE_OPENMP=$omp  -DBUILD_SHARED_LIBS=$shared -DGCC_TOOLCHAIN=$gcc_toolchain  -G "CodeBlocks - Unix Makefiles" ../../
    cmake --build . --target $target -- -j $make_threads
fi