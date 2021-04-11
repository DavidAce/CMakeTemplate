
if(CMT_PACKAGE_MANAGER MATCHES "conan")

    ##############################################################################
    ###  Required OpenMP support                                               ###
    ###  Note that Clang has some  trouble with static openmp and that         ###
    ###  and that static openmp is not recommended. This tries to enable       ###
    ###  static openmp anyway because I find it useful. Installing             ###
    ###  libiomp5 might help for shared linking.                               ###
    ##############################################################################
    if(CMT_ENABLE_OPENMP)
        find_package(OpenMP) # Uses DMRG's own find module
    endif()


    if(BUILD_SHARED_LIBS)
        list(APPEND CMT_CONAN_OPTIONS OPTIONS "*:shared=True")
    else()
        list(APPEND CMT_CONAN_OPTIONS OPTIONS "*:shared=False")
    endif()

    unset(CONAN_BUILD_INFO)
    unset(CONAN_BUILD_INFO CACHE)
    find_file(CONAN_BUILD_INFO
            conanbuildinfo.cmake
            HINTS ${CMAKE_BINARY_DIR} ${CMAKE_CURRENT_LIST_DIR}
            NO_DEFAULT_PATH)

    if(CONAN_BUILD_INFO)
        ##################################################################
        ### Use pre-existing conanbuildinfo.cmake                      ###
        ### This avoids having to run conan again                      ###
        ##################################################################
        message(STATUS "Detected Conan build info: ${CONAN_BUILD_INFO}")
        include(${CONAN_BUILD_INFO})
        conan_basic_setup(KEEP_RPATHS TARGETS)
    else()

        ##################################################################
        ### Use cmake-conan integration to launch conan                ###
        ### Install dependencies from conanfile.txt                    ###
        ### This uses conan to get spdlog,eigen3,h5pp,ceres-solver     ###
        ###    ceres-solver/2.0.0@davidace/development                 ###
        ###    h5pp/1.8.5@davidace/stable                              ###
        ###    eigen/3.3.9@davidace/patched                            ###
        ##################################################################

        find_program (
                CONAN_COMMAND
                conan
                HINTS ${CONAN_PREFIX} $ENV{CONAN_PREFIX} ${CONDA_PREFIX} $ENV{CONDA_PREFIX}
                PATHS $ENV{HOME}/anaconda3  $ENV{HOME}/miniconda3 $ENV{HOME}/anaconda $ENV{HOME}/miniconda $ENV{HOME}/.conda
                PATH_SUFFIXES bin envs/dmrg/bin
        )
        if(NOT CONAN_COMMAND)
            message(FATAL_ERROR "Could not find conan program executable")
        else()
            message(STATUS "Found conan: ${CONAN_COMMAND}")
        endif()

        # Download cmake-conan automatically, you can also just copy the conan.cmake file
        if(NOT EXISTS "${CMAKE_BINARY_DIR}/conan.cmake")
            message(STATUS "Downloading conan.cmake from https://github.com/conan-io/cmake-conan")
            file(DOWNLOAD "https://github.com/conan-io/cmake-conan/raw/v0.15/conan.cmake"
                    "${CMAKE_BINARY_DIR}/conan.cmake")
        endif()

        include(${CMAKE_BINARY_DIR}/conan.cmake)
        conan_add_remote(NAME conan-dmrg URL https://api.bintray.com/conan/davidace/conan-dmrg)

        conan_cmake_run(
                CONANFILE conanfile.txt
                CONAN_COMMAND ${CONAN_COMMAND}
                BUILD_TYPE ${CMAKE_BUILD_TYPE}
                BASIC_SETUP CMAKE_TARGETS
                SETTINGS compiler.cppstd=17
                SETTINGS compiler.libcxx=libstdc++11
                PROFILE_AUTO ALL
                ${CMT_CONAN_OPTIONS}
                KEEP_RPATHS
                BUILD missing
        )

    endif()

    if(TARGET CONAN_PKG::eigen AND CMT_ENABLE_THREADS)
        target_compile_definitions(CONAN_PKG::eigen INTERFACE EIGEN_USE_THREADS)
    endif()


    # Gather the targets
    if(TARGET CONAN_PKG::h5pp)
        target_link_libraries(cmt-settings INTERFACE CONAN_PKG::h5pp)
    endif()
    if(TARGET CONAN_PKG::eigen)
        target_link_libraries(cmt-settings INTERFACE CONAN_PKG::eigen)
    endif()

    if(TARGET openmp::openmp)
        target_link_libraries(cmt-settings INTERFACE openmp::openmp)
    else()
        target_compile_options(cmt-settings INTERFACE -Wno-unknown-pragmas)
    endif()
endif()
