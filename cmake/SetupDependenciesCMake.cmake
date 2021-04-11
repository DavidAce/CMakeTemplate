if(CMT_PACKAGE_MANAGER MATCHES "find|cmake")

    ##############################################################################
    ###  Optional OpenMP support                                               ###
    ###  Note that Clang has some  trouble with static openmp and that         ###
    ###  and that static openmp is not recommended. This tries to enable       ###
    ###  static openmp anyway because I find it useful. Installing             ###
    ###  libiomp5 might help for shared linking.                               ###
    ##############################################################################
    if(CMT_ENABLE_OPENMP)
        find_package(OpenMP) # Uses DMRG's own find module
    endif()
    include(cmake/Get_Eigen3.cmake)                       # Eigen3 numerical library (needed by ceres and h5pp)
    include(cmake/Get_h5pp.cmake)                         # h5pp for writing to file binary in format


    if(TARGET Eigen3::Eigen AND CMT_ENABLE_THREADS)
        target_compile_definitions(Eigen3::Eigen INTERFACE EIGEN_USE_THREADS)
    endif()


    ##################################################################
    ### Link all the things!                                       ###
    ##################################################################
    if(TARGET h5pp::h5pp)
        target_link_libraries(cmt-settings INTERFACE h5pp::h5pp)
    endif()
    if(TARGET Eigen3::Eigen)
        target_link_libraries(cmt-settings INTERFACE Eigen3::Eigen)
    endif()

    if(TARGET openmp::openmp)
        target_link_libraries(cmt-settings INTERFACE openmp::openmp)
    else()
        target_compile_options(cmt-settings INTERFACE -Wno-unknown-pragmas)
    endif()
endif()