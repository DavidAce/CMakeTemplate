
include(GNUInstallDirs)
if (NOT TARGET spdlog::spdlog)
    find_package(spdlog 1.3 NO_DEFAULT_PATH HINTS ${INSTALL_DIRECTORY}/spdlog/${CMAKE_INSTALL_LIBDIR}/cmake/spdlog ${spdlog_DIR} )

    if(spdlog_FOUND)
        get_target_property(SPDLOG_INCLUDE_DIR spdlog::spdlog INTERFACE_INCLUDE_DIRECTORIES)
        message(STATUS "SPDLOG FOUND IN SYSTEM: ${SPDLOG_INCLUDE_DIR}")

    elseif (DOWNLOAD_MISSING)
        message(STATUS "Spdlog will be installed into ${INSTALL_DIRECTORY}/spdlog on first build.")
        include(ExternalProject)
        ExternalProject_Add(external_SPDLOG
                GIT_REPOSITORY https://github.com/gabime/spdlog.git
                GIT_TAG v1.3.1
                GIT_PROGRESS false
                GIT_SHALLOW true
                UPDATE_COMMAND ""
                TEST_COMMAND ""
                PREFIX      ${BUILD_DIRECTORY}/spdlog
                INSTALL_DIR ${INSTALL_DIRECTORY}/spdlog
                CMAKE_ARGS
                -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
                -DCMAKE_BUILD_TYPE=Release
                -DSPDLOG_BUILD_EXAMPLES:BOOL=OFF
                -DSPDLOG_BUILD_BENCH:BOOL=OFF
                -DSPDLOG_BUILD_TESTS:BOOL=OFF
                -DCMAKE_INSTALL_MESSAGE=NEVER #Avoid unnecessary output to console
                )

        ExternalProject_Get_Property(external_SPDLOG INSTALL_DIR)
        add_library(spdlog INTERFACE)
        add_library(spdlog::spdlog ALIAS spdlog)
        set(spdlog_DIR ${INSTALL_DIR}/${CMAKE_INSTALL_LIBDIR}/cmake/spdlog)
        add_dependencies(spdlog external_SPDLOG)
        target_include_directories(spdlog SYSTEM INTERFACE ${INSTALL_DIR}/${CMAKE_INSTALL_INCLUDEDIR})
    else()
        message("WARNING: Dependency spdlog not found and DOWNLOAD_MISSING is OFF. Build will fail.")
    endif()
endif()