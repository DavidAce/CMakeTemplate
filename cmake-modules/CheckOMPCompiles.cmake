
if (NOT ENABLE_OPENMP)
    return()
endif()

if (NOT DEFINED MKLROOT)
    set(MKLROOT  "/opt/intel/mkl")
    message(STATUS "MKLROOT is not defined. Setting default: /opt/intel/mkl")
endif()
if(NOT DEFINED ENV{MKLROOT})
    set(ENV{MKLROOT}  "/opt/intel/mkl")
    message(STATUS "ENV MKLROOT is not defined. Setting default: /opt/intel/mkl")
endif()


if (NOT CUSTOM_SUFFIX)
    if(BUILD_SHARED_LIBS)
        set(CUSTOM_SUFFIX ${CMAKE_SHARED_LIBRARY_SUFFIX})
        set(CMAKE_FIND_LIBRARY_SUFFIXES ${CUSTOM_SUFFIX} ${CMAKE_FIND_LIBRARY_SUFFIXES})
    else()
        set(CUSTOM_SUFFIX ${CMAKE_STATIC_LIBRARY_SUFFIX})
        set(CMAKE_FIND_LIBRARY_SUFFIXES ${CUSTOM_SUFFIX} ${CMAKE_FIND_LIBRARY_SUFFIXES})
    endif()
endif()


if (NOT TARGET Threads::Threads)
    ##################################################
    ###  Adapt pthread linking for static/dynamic  ###
    ##################################################
    set(CMAKE_THREAD_PREFER_PTHREAD TRUE)
    set(THREADS_PREFER_PTHREAD_FLAG FALSE)
    find_package(Threads REQUIRED)
    if(NOT BUILD_SHARED_LIBS)
        set_target_properties(Threads::Threads PROPERTIES INTERFACE_LINK_LIBRARIES "-Wl,--whole-archive ${CMAKE_THREAD_LIBS_INIT} -Wl,--no-whole-archive")
    endif()
endif()



function(check_omp_compiles REQUIRED_FLAGS REQUIRED_LIBRARIES_UNPARSED REQUIRED_INCLUDES)
    include(CheckIncludeFileCXX)

    set(REQUIRED_LIBRARIES)
    foreach(elem ${REQUIRED_LIBRARIES_UNPARSED})
        if(TARGET ${elem})
            get_target_property(lib ${elem} INTERFACE_LINK_LIBRARIES)
            list(APPEND REQUIRED_LIBRARIES ${lib})
        else()
            list(APPEND REQUIRED_LIBRARIES ${elem})
        endif()
    endforeach()


    set(CMAKE_REQUIRED_FLAGS     "${REQUIRED_FLAGS}" )
    set(CMAKE_REQUIRED_LIBRARIES "${REQUIRED_LIBRARIES}")
    set(CMAKE_REQUIRED_INCLUDES  "${REQUIRED_INCLUDES}")

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
        #        message(STATUS "Unable to compile a simple OpenMP program")
        set(OMP_COMPILES FALSE PARENT_SCOPE)
    else()
        #        message(STATUS "Unable to compile a simple OpenMP program")
        set(OMP_COMPILES TRUE PARENT_SCOPE)
    endif()
endfunction()



function(find_package_omp omp_paths omp_names BUILD_SHARED_LIBS )
    # Start by trying to find it using the normal methods
    # find_package(OpenMP) Will at least find the correct header?
    find_package(OpenMP)
    if (OpenMP_FOUND)
        include(cmake-modules/PrintTargetProperties.cmake)
        #print_target_properties(OpenMP::OpenMP_CXX)
        set(OpenMP_LIBRARIES  ${OpenMP_gomp_LIBRARY} ${OpenMP_omp_LIBRARY} ${OpenMP_iomp_LIBRARY})
        set(OpenMP_FLAGS ${OpenMP_CXX_FLAGS})

        # Try to find the header omp.h
        get_filename_component("OpenMP_ROOT" "${OpenMP_LIBRARIES}" DIRECTORY)
        set(OpenMP_HEADER_PATHS  ${OpenMP_ROOT}/../../include ${OpenMP_ROOT}/../include ${OpenMP_ROOT}/include)


        find_path(OpenMP_INCLUDE_DIR NAMES omp.h PATHS ${OpenMP_HEADER_PATHS} ${omp_paths} PATH_SUFFIXES openmp include)
        list(APPEND OpenMP_LIBRARIES  Threads::Threads -ldl)
        message(STATUS "OpenMP libraries found: ${OpenMP_LIBRARIES}" )
        if(BUILD_SHARED_LIBS)
            check_omp_compiles("${OpenMP_FLAGS}" "${OpenMP_LIBRARIES}" "${OpenMP_INCLUDE_DIR}")
        else()
            check_omp_compiles("${OpenMP_FLAGS}" "-static;${OpenMP_LIBRARIES}" "${OpenMP_INCLUDE_DIR}")
        endif()
    endif()



    if(NOT OMP_COMPILES)
        message(STATUS "Checking for OpenMP in given paths: ${omp_paths}")

        unset(OpenMP_FOUND)
        unset(OpenMP_FOUND CACHE)
        unset(OpenMP_LIBRARIES)
        unset(OpenMP_LIBRARIES CACHE)


        find_library(OpenMP_LIBRARIES NAMES ${omp_names} PATHS ${omp_paths})
        find_path(OpenMP_INCLUDE_DIR NAMES omp.h PATHS ${OpenMP_HEADER_PATHS} ${omp_paths} /usr/lib  /usr/lib/llvm-9/include /usr/include /usr/lib/llvm-8/include PATH_SUFFIXES openmp include)
        if(OpenMP_LIBRARIES AND OpenMP_INCLUDE_DIR)
            list(APPEND OpenMP_LIBRARIES Threads::Threads -ldl)
            set(OpenMP_FLAGS "-D_OPENMP")
            if(${BUILD_SHARED_LIBS})
                check_omp_compiles("${OpenMP_FLAGS}" "${OpenMP_LIBRARIES}" "${OpenMP_INCLUDE_DIR}")
            else()
                check_omp_compiles("${OpenMP_FLAGS}" "-static;${OpenMP_LIBRARIES}" "${OpenMP_INCLUDE_DIR}")
            endif()
        else()
            message("OpenMP_LIBRARIES    : ${OpenMP_LIBRARIES} ")
            message("OpenMP_INCLUDE_DIR  : ${OpenMP_INCLUDE_DIR} ")
        endif()
    endif()

    if(OMP_COMPILES)
        message(STATUS "OpenMP found" )
        set(OpenMP_FOUND        TRUE                    PARENT_SCOPE)
        set(OpenMP_LIBRARIES    ${OpenMP_LIBRARIES}     PARENT_SCOPE)
        set(OpenMP_INCLUDE_DIR  ${OpenMP_INCLUDE_DIR}   PARENT_SCOPE)
        set(OpenMP_FLAGS        ${OpenMP_FLAGS}         PARENT_SCOPE)
        set(USE_OpenMP          TRUE                    PARENT_SCOPE)
        set(OMP_COMPILES        TRUE                    PARENT_SCOPE)
    else()
        message(WARNING "Setting USE_OpenMP OFF" )
        set(USE_OpenMP   FALSE PARENT_SCOPE)
        set(OMP_COMPILES FALSE PARENT_SCOPE)
    endif()

endfunction()


unset(OMP_HEADERTEST)
unset(OMP_HEADERTEST CACHE)

set(OMP_LIBRARY_NAMES)
set(OMP_LIBRARY_PATHS)
if("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang" AND NOT BUILD_SHARED_LIBS)
    list(APPEND OMP_LIBRARY_NAMES libiomp5${CUSTOM_SUFFIX} libiomp${CUSTOM_SUFFIX})
    list(APPEND OMP_LIBRARY_PATHS
            ${MKLROOT}/../intel/lib/intel64  ${MKL_ROOT}/../intel/lib/intel64
            $ENV{MKLROOT}/../intel/lib/intel64 $ENV{MKL_ROOT}/../intel/lib/intel64
            $ENV{EBROOTIMKL}/../intel/lib/intel64
            /opt/intel/lib/intel64
            )
    foreach(omp_name ${OMP_LIBRARY_NAMES})
        execute_process(COMMAND ${CMAKE_CXX_COMPILER} -print-file-name=${omp_name}
                OUTPUT_VARIABLE OMP_LIB
                OUTPUT_STRIP_TRAILING_WHITESPACE
                )
        get_filename_component(OMP_PATH ${OMP_LIB} DIRECTORY)
        if(OMP_PATH)
            list(APPEND OMP_LIBRARY_PATHS ${OMP_PATH})
            message(STATUS "Inserting: ${OMP_PATH}")
        endif()
    endforeach()
endif()



find_package_omp("${OMP_LIBRARY_PATHS}" "${OMP_LIBRARY_NAMES}" "${BUILD_SHARED_LIBS}")

if (OpenMP_FOUND)
    add_library(OpenMP INTERFACE)
    target_link_libraries(OpenMP INTERFACE ${OpenMP_LIBRARIES} ${OpenMP_FLAGS})
    target_compile_options(OpenMP INTERFACE ${OpenMP_FLAGS})
    target_include_directories(OpenMP INTERFACE ${OpenMP_INCLUDE_DIR})
endif()

