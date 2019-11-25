
include(GNUInstallDirs)
find_package(spdlog 1.3
        PATHS ${EXTERNAL_INSTALL_DIR}/spdlog/${CMAKE_INSTALL_LIBDIR}/cmake/spdlog ${spdlog_DIR} ${DIRECTORY_HINTS}
        PATH_SUFFIXES spdlog spdlog/${CMAKE_INSTALL_LIBDIR} spdlog/share spdlog/cmake
        NO_DEFAULT_PATH  )

if(spdlog_FOUND AND TARGET spdlog::spdlog)
    message(STATUS "spdlog found")

elseif (DOWNLOAD_MISSING)
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
    if(spdlog_FOUND AND TARGET spdlog::spdlog)
        message(STATUS "spdlog installed successfully")
    else()
        message(STATUS "config_result: ${config_result}")
        message(STATUS "build_result: ${build_result}")
        message(FATAL_ERROR "Spdlog could not be downloaded.")
    endif()

else()
    message(FATAL_ERROR "Dependency spdlog not found and DOWNLOAD_MISSING is OFF")

endif()