
find_package(h5pp PATHS ${INSTALL_DIRECTORY}/h5pp $ENV{H5PP_DIR})

if(h5pp_FOUND)
    message(STATUS "h5pp FOUND IN SYSTEM: ${H5PP_ROOT}")
#    add_library(h5pp ALIAS h5pp::h5pp)
else()
    message(STATUS "h5pp will be installed into ${INSTALL_DIRECTORY}/h5pp on first build.")

    include(ExternalProject)
    ExternalProject_Add(external_H5PP
            GIT_REPOSITORY https://github.com/DavidAce/h5pp.git
            GIT_TAG master
            GIT_PROGRESS false
            PREFIX      ${BUILD_DIRECTORY}/h5pp
            INSTALL_DIR ${INSTALL_DIRECTORY}/h5pp
#            BUILD_ALWAYS 1
            UPDATE_COMMAND ""
            CMAKE_ARGS
            -DCMAKE_BUILD_TYPE=Release
            -DENABLE_TESTS:BOOL=ON
            -DDOWNLOAD_ALL:BOOL=ON
            -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
            -Dspdlog_DIR:PATH=${spdlog_DIR}
            -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
            DEPENDS spdlog::spdlog
            )

    ExternalProject_Get_Property(external_H5PP INSTALL_DIR)
    add_library(h5pp INTERFACE)
    add_library(h5pp::h5pp ALIAS h5pp)
    target_link_libraries(h5pp  INTERFACE -lstdc++fs)
    target_compile_options(h5pp  INTERFACE -std=c++17)
    target_compile_features(h5pp INTERFACE cxx_std_17)

    set(H5PP_INCLUDE_DIR ${INSTALL_DIR}/include)
    add_dependencies(h5pp external_H5PP)
    add_dependencies(h5pp spdlog::spdlog)
    target_include_directories(h5pp INTERFACE ${H5PP_INCLUDE_DIR})
endif()
