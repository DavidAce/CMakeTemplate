
include(GNUInstallDirs)
find_package(spdlog 1.3
        PATHS  ${spdlog_DIR} ${CMAKE_INSTALL_PREFIX} ${CMAKE_BINARY_DIR}/deps-install
        PATH_SUFFIXES ${spdlog_suffix}${CMAKE_INSTALL_LIBDIR}/cmake/spdlog spdlog spdlog/${CMAKE_INSTALL_LIBDIR} spdlog/share spdlog/cmake)

if(NOT TARGET spdlog::spdlog)
    find_path(SPDLOG_INCLUDE_DIR
            NAMES spdlog/spdlog.h
            PATHS /usr /usr/local ${spdlog_DIR} ${CMAKE_INSTALL_PREFIX} ${CMAKE_BINARY_DIR}/deps-install)
    # Check for a file in new enough spdlog versions
    find_path(SPDLOG_COLOR_SINKS
            NAMES spdlog/sinks/stdout_color_sinks.h
            PATHS /usr /usr/local ${spdlog_DIR} ${CMAKE_INSTALL_PREFIX} ${CMAKE_BINARY_DIR}/deps-install ${SPDLOG_INCLUDE_DIR})
    if(SPDLOG_INCLUDE_DIR AND SPDLOG_COLOR_SINKS)
        set(spdlog_FOUND TRUE)
        add_library(spdlog::spdlog INTERFACE IMPORTED)
        target_include_directories(spdlog::spdlog INTERFACE ${SPDLOG_INCLUDE_DIR})
    endif()
endif()



if(TARGET spdlog::spdlog)
    message(STATUS "spdlog found in system")


elseif (DOWNLOAD_MISSING)
    if(DOWNLOAD_METHOD_CMAKE)
        message(STATUS "Spdlog will be installed into ${CMAKE_BINARY_DIR}/deps-install/spdlog")
        include(${PROJECT_SOURCE_DIR}/cmake-modules/BuildDependency.cmake)
        build_dependency(spdlog "")
        find_package(spdlog 1.3
                PATHS  ${spdlog_DIR} ${CMAKE_INSTALL_PREFIX} ${CMAKE_BINARY_DIR}/deps-install
                PATH_SUFFIXES ${CMAKE_INSTALL_LIBDIR}/cmake/spdlog spdlog spdlog/${CMAKE_INSTALL_LIBDIR} spdlog/share spdlog/cmake
                NO_DEFAULT_PATH NO_CMAKE_PACKAGE_REGISTRY )

    elseif(DOWNLOAD_METHOD_CONAN)
        # New fancy way with conan. Requires conan, obviously
        include(conan-modules/conan.cmake)
        conan_cmake_run(REQUIRES spdlog/1.4.2@bincrafters/stable
                BASIC_SETUP CMAKE_TARGETS
                BUILD missing)
        add_library (spdlog::spdlog INTERFACE IMPORTED)
        target_link_libraries(spdlog::spdlog INTERFACE CONAN_PKG::spdlog)
    else()
        message(FATAL_ERROR "Requested download of missing library spdlog but no download method selected")
    endif()
    if(TARGET spdlog::spdlog)
        message(STATUS "spdlog installed successfully")
#        include(cmake-modules/PrintTargetProperties.cmake)
#        print_target_properties(spdlog::spdlog)
    else()
        message(STATUS "config_result: ${config_result}")
        message(STATUS "build_result: ${build_result}")
        message(FATAL_ERROR "Spdlog could not be downloaded.")
    endif()

else()
    message(STATUS "Dependency spdlog not found and DOWNLOAD_MISSING is OFF")

endif()