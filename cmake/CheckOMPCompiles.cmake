function(check_omp_compiles REQUIRED_FLAGS REQUIRED_LIBRARIES_UNPARSED REQUIRED_INCLUDES)
    include(CheckIncludeFileCXX)
    include(cmake/getExpandedTarget.cmake)
    expand_target_libs("${REQUIRED_LIBRARIES_UNPARSED}" expanded_libs)
    expand_target_incs("${REQUIRED_LIBRARIES_UNPARSED}" expanded_incs)
    expand_target_opts("${REQUIRED_LIBRARIES_UNPARSED}" expanded_opts)
    set(CMAKE_REQUIRED_LIBRARIES "${expanded_libs}") # Can be a ;list
    set(CMAKE_REQUIRED_INCLUDES  "${REQUIRED_INCLUDES};${expanded_incs}") # Can be a ;list
    string(REPLACE ";" " " CMAKE_REQUIRED_FLAGS      "${REQUIRED_FLAGS} ${expanded_opts}") # Needs to be a space-separated list


    unset(has_omp_h)
    unset(has_omp_h CACHE)
    unset(OMP_COMPILES CACHE)
    unset(OMP_COMPILES)

    check_include_file_cxx(omp.h    has_omp_h)
    include(CheckCXXSourceCompiles)
    check_cxx_source_compiles("
            #include <omp.h>
            #include <iostream>
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