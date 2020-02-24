

# This makes sure we use our modules to find dependencies!
list(INSERT CMAKE_MODULE_PATH 0 ${PROJECT_SOURCE_DIR}/cmake)


if(ENABLE_OPENMP)
    find_package(OpenMP REQUIRED) # Uses DMRG's own find module
    ##############################################################################
    ###  Optional OpenMP support                                               ###
    ###  Note that Clang has some  trouble with static openmp and that         ###
    ###  and that static openmp is not recommended. This tries to enable       ###
    ###  static openmp anyway because I find it useful. Installing             ###
    ###  libiomp5 might help for shared linking.                               ###
    ##############################################################################
    if(TARGET openmp::openmp)
        target_link_libraries(project-settings INTERFACE openmp::openmp)
    else()
        target_compile_options(project-settings INTERFACE -Wno-unknown-pragmas)
    endif()
endif()


if(ENABLE_SPDLOG)
    include(${PROJECT_SOURCE_DIR}/cmake/Fetch_spdlog.cmake)
    target_link_libraries(project-settings INTERFACE spdlog::spdlog)
endif()


if(ENABLE_EIGEN3)
    include(${PROJECT_SOURCE_DIR}/cmake/Fetch_Eigen3.cmake)
    target_link_libraries(project-settings INTERFACE Eigen3::Eigen)
endif()


if(ENABLE_H5PP)
    include(${PROJECT_SOURCE_DIR}/cmake/Fetch_h5pp.cmake)
    target_link_libraries(project-settings INTERFACE h5pp::h5pp)
endif()




include(cmake/PrintTargetInfo.cmake)
print_target_info(h5pp::h5pp)
print_target_info(spdlog::spdlog)
print_target_info(Eigen3::Eigen)
print_target_info(openmp::openmp)
print_target_info(project-settings)

