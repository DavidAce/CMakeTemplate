if(CMT_PRINT_INFO)
    # Print CMake options
    message(STATUS  "|----------------\n"
            "-- | CMAKE_INSTALL_PREFIX   : ${CMAKE_INSTALL_PREFIX}\n"
            "-- | CMAKE_VERBOSE_MAKEFILE : ${CMAKE_VERBOSE_MAKEFILE}\n"
            "-- | BUILD_SHARED_LIBS      : ${BUILD_SHARED_LIBS}\n"
            "-- | CMT_ENABLE_THREADS    : ${CMT_ENABLE_THREADS}\n"
            "-- | CMT_ENABLE_OPENMP     : ${CMT_ENABLE_OPENMP}\n"
            "-- | CMT_ENABLE_MKL        : ${CMT_ENABLE_MKL}\n"
            "-- | CMT_ENABLE_TESTS      : ${CMT_ENABLE_TESTS}\n"
            "-- | CMT_ENABLE_ASAN       : ${CMT_ENABLE_ASAN}\n"
            "-- | CMT_ENABLE_USAN       : ${CMT_ENABLE_USAN}\n"
            "-- | CMT_ENABLE_LTO        : ${CMT_ENABLE_LTO}\n"
            "-- | CMT_ENABLE_PCH        : ${CMT_ENABLE_PCH}\n"
            "-- | CMT_ENABLE_CCACHE     : ${CMT_ENABLE_CCACHE}\n"
            "-- | CMT_BUILD_EXAMPLES    : ${CMT_BUILD_EXAMPLES}\n"
            "-- | CMT_PACKAGE_MANAGER   : ${CMT_PACKAGE_MANAGER}\n"
            "-- | CMT_PRINT_INFO        : ${CMT_PRINT_INFO}\n"
            "-- | CMT_PRINT_CHECKS      : ${CMT_PRINT_CHECKS}\n"
            "-- | CMT_DEPS_IN_SUBDIR    : ${CMT_DEPS_IN_SUBDIR}\n"
            "-- | CMT_PREFER_CONDA_LIBS : ${CMT_PREFER_CONDA_LIBS}\n")
endif ()
