
function(strip_genex input_string output_string)
    set(result_string)
    foreach(elem ${input_string})
        if(${elem} MATCHES "[$]")
            string(REGEX MATCHALL "([-=]+[a-z0-9]+)" filtered_string "${input_string}")
            list(APPEND result_string ${filtered_string})
        else()
            list(APPEND result_string ${elem})
        endif()
    endforeach()
    set(${output_string} ${result_string} PARENT_SCOPE)
endfunction()


function(check_omp_compiles REQUIRED_FLAGS REQUIRED_LIBRARIES_UNPARSED REQUIRED_INCLUDES)
    include(CheckIncludeFileCXX)
    include(cmake/getExpandedTarget.cmake)
    expand_target_libs("${REQUIRED_LIBRARIES_UNPARSED}" expanded_libs)
    expand_target_incs("${REQUIRED_LIBRARIES_UNPARSED}" expanded_incs)
    expand_target_opts("${REQUIRED_LIBRARIES_UNPARSED}" expanded_opts)

    strip_genex("${expanded_libs}"     expanded_libs)
    strip_genex("${expanded_incs}"     expanded_incs)
    strip_genex("${expanded_opts}"     expanded_opts)
    strip_genex("${REQUIRED_INCLUDES}" REQUIRED_INCLUDES)
    strip_genex("${REQUIRED_FLAGS}"    REQUIRED_FLAGS)

    set(CMAKE_REQUIRED_LIBRARIES "${expanded_libs}") # Can be a ;list
    set(CMAKE_REQUIRED_INCLUDES  "${REQUIRED_INCLUDES};${expanded_incs}") # Can be a ;list
    string(REPLACE ";" " " CMAKE_REQUIRED_FLAGS "${REQUIRED_FLAGS} ${expanded_opts}") # Needs to be a space-separated list
    unset(has_omp_h)
    unset(has_omp_h CACHE)
    unset(OMP_COMPILES)
    unset(OMP_COMPILES CACHE)

    check_include_file_cxx(omp.h    has_omp_h)
    include(CheckCXXSourceCompiles)
    check_cxx_source_compiles("
            #include <omp.h>
            #include <iostream>
            #ifndef _OPENMP
            #error You forgot to define _OPENMP
            #endif
            int main() {
                omp_set_num_threads(4);
                std::cout << \"OMP Threads \" << omp_get_max_threads() << std::endl;
                int counter = 0;
                #pragma omp parallel for shared(counter)
                for(int i = 0; i < 16; i++){
                    #pragma omp atomic
                    counter++;
                }
                std::cout << \"Counter is: \" << counter << std::endl;

                return 0;
            }
            " OMP_COMPILES
            )
    if(NOT OMP_COMPILES)
        set(OMP_COMPILES FALSE PARENT_SCOPE)
    else()
        set(OMP_COMPILES TRUE PARENT_SCOPE)
    endif()
endfunction()





if(NOT OpenMP_FOUND AND NOT TARGET openmp::openmp AND BUILD_SHARED_LIBS)
    find_package(OpenMP)
endif()



if(NOT OpenMP_FOUND)

    list(APPEND omp_lib_candidates gomp omp iomp5)
    if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        # MKL comes with a useable iomp5 library
        find_path(MKL_ROOT_DIR
                include/mkl.h
                HINTS ${CMAKE_INSTALL_PREFIX} ${CONDA_HINTS}
                PATHS
                $ENV{MKL_DIR}  ${MKL_DIR}
                $ENV{MKLDIR}   ${MKLDIR}
                $ENV{MKLROOT}  ${MKLROOT}
                $ENV{MKL_ROOT} ${MKL_ROOT}
                $ENV{mkl_root} ${mkl_root}
                $ENV{EBROOTIMKL}
                $ENV{HOME}/intel/mkl
                /opt/intel/mkl
                /opt/intel
                $ENV{BLAS_DIR}
                $ENV{CONDA_PREFIX}
                /usr/lib/x86_64-linux-gnu
                /Library/Frameworks/Intel_MKL.framework/Versions/Current/lib/universal
                "Program Files (x86)/Intel/ComposerXE-2011/mkl"
                PATH_SUFFIXES
                intel intel/mkl mkl lib
                )

        find_library(omp_lib_iomp5 NAMES iomp5
                PATHS
                /usr/lib/llvm-9
                /usr/lib/llvm-8
                /usr/lib/llvm-7
                /usr
                ${MKL_ROOT_DIR}
                /opt/intel/lib/intel64
                PATH_SUFFIXES
                include lib local ../intel/lib/intel64
                )
        if(omp_lib_iomp5)
            list(APPEND omp_lib_candidates ${omp_lib_iomp5})
        endif()

    endif()


    foreach(lib ${omp_lib_candidates})
        check_omp_compiles("-D_OPENMP" "-static;${lib};pthread;rt;dl" "")
        if(OMP_COMPILES)
            set(OMP_LIBRARY ${lib})
            break()
        endif()
    endforeach()
endif()


include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(OpenMP DEFAULT_MSG OMP_COMPILES)



if(OMP_COMPILES)
    add_library(openmp::openmp INTERFACE IMPORTED)
    if(TARGET OpenMP::OpenMP_CXX)
        target_link_libraries(openmp::openmp INTERFACE OpenMP::OpenMP_CXX)
    else()
        target_link_libraries(openmp::openmp INTERFACE ${OMP_LIBRARY} pthread rt dl)
        target_compile_definitions(openmp::openmp INTERFACE -D_OPENMP)
    endif()
endif()
