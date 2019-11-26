
include(GNUInstallDirs)
find_package(spdlog 1.3
        PATHS ${EXTERNAL_INSTALL_DIR}/spdlog/${CMAKE_INSTALL_LIBDIR}/cmake/spdlog ${spdlog_DIR} ${DIRECTORY_HINTS}
        PATH_SUFFIXES spdlog spdlog/${CMAKE_INSTALL_LIBDIR} spdlog/share spdlog/cmake
        NO_DEFAULT_PATH  )

if(spdlog_FOUND AND TARGET spdlog::spdlog)
    message(STATUS "spdlog found")

elseif (DOWNLOAD_MISSING)
    # We do it good ol' way with externalprojectadd
    if(DOWNLOAD_METHOD_CMAKE)

        message(STATUS "Spdlog will be installed into ${EXTERNAL_INSTALL_DIR}/spdlog on first build.")
        include(cmake-modules/BuildExternalLibs.cmake)
        build_external_libs(
                "spdlog"
                "${EXTERNAL_CONFIG_DIR}"
                "${EXTERNAL_BUILD_DIR}"
                "${EXTERNAL_INSTALL_DIR}"
                ""
        )
        message("Looking in: ${EXTERNAL_INSTALL_DIR}/spdlog/${CMAKE_INSTALL_LIBDIR}/cmake/spdlog")
        find_package(spdlog 1.3 NO_DEFAULT_PATH PATHS ${EXTERNAL_INSTALL_DIR}/spdlog/${CMAKE_INSTALL_LIBDIR}/cmake/spdlog)

    elseif(DOWNLOAD_METHOD_CONAN)
        # New fancy way with conan. Requires conan, obviously
        include(conan-modules/conan.cmake)
        conan_cmake_run(REQUIRES spdlog/1.4.2@bincrafters/stable
                BASIC_SETUP CMAKE_TARGETS
                BUILD missing)
        add_library (spdlog::spdlog INTERFACE IMPORTED)
        target_link_libraries(spdlog::spdlog INTERFACE CONAN_PKG::spdlog)
    else()
        message(FATAL_ERROR "Requested download of missing library [spdlog] but no download method selected")
    endif()

    # Report if package found or not
    if(TARGET spdlog::spdlog)
        message(STATUS "spdlog installed successfully")
    else()
        message(STATUS "config_result: ${config_result}")
        message(STATUS "build_result: ${build_result}")
        message(FATAL_ERROR "Spdlog could not be downloaded.")
    endif()
else()
    message(FATAL_ERROR "Dependency spdlog not found and DOWNLOAD_MISSING is OFF")

endif()