function(find_package_openmp_internal omp_paths omp_names BUILD_SHARED_LIBS )
    include(${PROJECT_SOURCE_DIR}/cmake/CheckOMPCompiles.cmake)
    # Start by trying to find it using the normal methods
    # find_package(OpenMP) Will at least find the correct header?
    find_package(OpenMP)
    if (OpenMP_FOUND)
      include(cmake/PrintTargetProperties.cmake)
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
      unset(OpenMP_INCLUDE_DIR)
      unset(OpenMP_INCLUDE_DIR CACHE)

      find_library(OpenMP_LIBRARIES NAMES ${omp_names} PATHS ${omp_paths})
      find_path(OpenMP_INCLUDE_DIR NAMES omp.h PATHS ${OpenMP_HEADER_PATHS} ${omp_paths} /usr/lib  /usr/lib/llvm-9/include /usr/include /usr/lib/llvm-8/include PATH_SUFFIXES openmp include)
      if(NOT OpenMP_LIBRARIES)
          unset(OpenMP_LIBRARIES)
          unset(OpenMP_LIBRARIES CACHE)
      endif()
      if(NOT OpenMP_INCLUDE_DIR)
          unset(OpenMP_INCLUDE_DIR)
          unset(OpenMP_INCLUDE_DIR CACHE)
      endif()
      #        message("OpenMP_LIBRARIES    : ${OpenMP_LIBRARIES}")
      #        message("OpenMP_INCLUDE_DIR  : ${OpenMP_INCLUDE_DIR}")
      list(APPEND OpenMP_LIBRARIES Threads::Threads -ldl)
      set(OpenMP_FLAGS "-D_OPENMP")
      if(${BUILD_SHARED_LIBS})
          check_omp_compiles("${OpenMP_FLAGS}" "${OpenMP_LIBRARIES}" "${OpenMP_INCLUDE_DIR}")
      else()
          check_omp_compiles("${OpenMP_FLAGS}" "-static;${OpenMP_LIBRARIES}" "${OpenMP_INCLUDE_DIR}")
      endif()
    endif()

    if(OMP_COMPILES)
      set(OpenMP_FOUND        TRUE                    PARENT_SCOPE)
      set(ENABLE_OPENMP       TRUE                    PARENT_SCOPE)
      add_library(OpenMP INTERFACE IMPORTED)
      target_link_libraries(OpenMP INTERFACE ${OpenMP_LIBRARIES} ${OpenMP_FLAGS})
      target_compile_options(OpenMP INTERFACE ${OpenMP_FLAGS})
      target_include_directories(OpenMP INTERFACE ${OpenMP_INCLUDE_DIR})
      message(STATUS "Found working OpenMP" )
    else()
      message(STATUS "Could not compile simle OpenMP program. Setting ENABLE_OPENMP OFF" )
      set(ENABLE_OPENMP FALSE PARENT_SCOPE)
      set(OMP_COMPILES FALSE PARENT_SCOPE)
    endif()
endfunction()


function(find_package_openmp)

    if (NOT ENABLE_OPENMP)
        message(STATUS "OpenMP not enabled")
        return()
    endif()

    if(USE_MKL AND NOT MKLROOT)
        if(DEFINED $ENV{MKLROOT})
            set(MKLROOT $ENV{MKLROOT})
        else()
            set(MKLROOT  /opt/intel/mkl)
            message(STATUS "MKLROOT is not defined. Setting default: ${MKLROOT}")
        endif()
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
        ### Adapt pthread for static/dynamic linking
        ### This is to fix a bug with threads described here:
        ### https://stackoverflow.com/questions/35116327/when-g-static-link-pthread-cause-segmentation-fault-why
        set(CMAKE_THREAD_PREFER_PTHREAD TRUE)
        set(THREADS_PREFER_PTHREAD_FLAG FALSE)
        find_package(Threads)
        if(TARGET Threads::Threads AND NOT BUILD_SHARED_LIBS)
            set_target_properties(Threads::Threads PROPERTIES INTERFACE_LINK_LIBRARIES "-Wl,--whole-archive ${CMAKE_THREAD_LIBS_INIT} -Wl,--no-whole-archive")
        endif()
    endif()



    set(OMP_LIBRARY_NAMES)
    set(OMP_LIBRARY_PATHS)
    if("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang" AND NOT BUILD_SHARED_LIBS)
        # Append possible locations for iomp5
        list(APPEND OMP_LIBRARY_NAMES  libiomp5${CUSTOM_SUFFIX} libiomp${CUSTOM_SUFFIX})
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
        list(APPEND OMP_LIBRARY_PATHS
                ${MKLROOT}/../intel/lib/intel64
                $ENV{EBROOTIMKL}/../intel/lib/intel64
                /opt/intel/lib/intel64
                )
    endif()

    find_package_openmp_internal("${OMP_LIBRARY_PATHS}" "${OMP_LIBRARY_NAMES}" "${BUILD_SHARED_LIBS}")
endfunction()

