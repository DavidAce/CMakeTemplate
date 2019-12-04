find_package(Eigen3 3.3.4
        PATHS ${Eigen3_DIR} ${CMAKE_INSTALL_PREFIX} ${CMAKE_BINARY_DIR}/deps-install
        PATH_SUFFIXES Eigen3 eigen3 include/Eigen3 include/eigen3  NO_CMAKE_PACKAGE_REGISTRY)

if(TARGET Eigen3::Eigen)
    message(STATUS "Eigen3 found")
#    include(cmake-modules/PrintTargetProperties.cmake)
#    print_target_properties(Eigen3::Eigen)

elseif (DOWNLOAD_MISSING)
    # We get the package for the user
    if(DOWNLOAD_METHOD_CMAKE)
        message(STATUS "Eigen3 will be installed into ${CMAKE_BINARY_DIR}/deps-install/Eigen3")
        include(${PROJECT_SOURCE_DIR}/cmake-modules/BuildDependency.cmake)
        build_dependency(Eigen3 "")
        find_package(Eigen3 3.3.4
                PATHS ${CMAKE_BINARY_DIR}/deps-install
                PATH_SUFFIXES Eigen3 eigen3 include/Eigen3 include/eigen3  NO_CMAKE_PACKAGE_REGISTRY NO_DEFAULT_PATH)
    elseif(DOWNLOAD_METHOD_CONAN)
        # This source provides an bug-patched version of Eigen that saves svd from segfault in som cases
#        conan_add_remote(NAME conan-dmrg INDEX 1
#                URL http://thinkstation.duckdns.org:8081/artifactory/api/conan/conan-dmrg)
        # New fancy way with conan. Requires conan, obviously
        conan_cmake_run(REQUIRES eigen/3.3.7@conan/stable
                BASIC_SETUP CMAKE_TARGETS
                BUILD missing)
        add_library (Eigen3::Eigen INTERFACE IMPORTED)
        target_link_libraries(Eigen3::Eigen INTERFACE CONAN_PKG::Eigen3)
    else()
        message(FATAL_ERROR "Requested download of missing library Eigen3 but no download method selected")
    endif()


    if(TARGET Eigen3::Eigen)
        message(STATUS "Eigen3 installed successfully")
    else()
        message(STATUS "cfg_result: ${cfg_result}")
        message(STATUS "bld_result: ${bld_result}")
        message(FATAL_ERROR "Eigen3 could not be downloaded.")
    endif()

else()
    message(STATUS "Dependency Eigen3 not found and DOWNLOAD_MISSING is OFF")
endif()


if(TARGET Eigen3::Eigen AND TARGET blas )
    set(EIGEN3_USING_BLAS ON)
    if(TARGET mkl)
        message(STATUS "Eigen3 will use MKL")
        target_compile_definitions    (Eigen3::Eigen INTERFACE -DEIGEN_USE_MKL_ALL)
        target_compile_definitions    (Eigen3::Eigen INTERFACE -DEIGEN_USE_LAPACKE_STRICT)
        target_compile_definitions    (Eigen3::Eigen INTERFACE -DEIGEN_USE_MKL_ALL)
        target_include_directories(Eigen3::Eigen INTERFACE ${MKL_INCLUDE_DIR})
    else ()
        message(STATUS "Eigen3 will use BLAS and LAPACKE")
        target_compile_definitions    (Eigen3::Eigen INTERFACE -DEIGEN_USE_BLAS)
        target_compile_definitions    (Eigen3::Eigen INTERFACE -DEIGEN_USE_LAPACKE_STRICT)
    endif()
endif()

