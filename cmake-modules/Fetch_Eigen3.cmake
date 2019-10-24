

if(NOT TARGET Eigen3::Eigen)
    message(STATUS "Searching for Eigen3")
    find_package(Eigen3 3.3.7  PATHS ${INSTALL_DIRECTORY}/Eigen3 NO_DEFAULT_PATH NO_MODULE)
    #find_package(Eigen3 3.3.4  PATHS ${INSTALL_DIRECTORY}/Eigen3 $ENV{EBROOTEIGEN} $ENV{HOME}/.conda  $ENV{HOME}/anaconda3 NO_DEFAULT_PATH NO_MODULE)
    #find_package(Eigen3 3.3.4  PATHS ${INSTALL_DIRECTORY}/Eigen3 $ENV{EBROOTEIGEN} $ENV{HOME}/.conda  $ENV{HOME}/anaconda3 NO_CMAKE_PACKAGE_REGISTRY NO_MODULE)
    #find_package(Eigen3 3.3.4  PATHS ${INSTALL_DIRECTORY}/Eigen3 $ENV{EBROOTEIGEN} $ENV{HOME}/.conda  $ENV{HOME}/anaconda3)
    if(TARGET Eigen3::Eigen)
        get_target_property(EIGEN3_INCLUDE_DIR Eigen3::Eigen INTERFACE_INCLUDE_DIRECTORIES)
        message(STATUS "Searching for Eigen3 - Success - | Version ${EIGEN3_VERSION} | ${EIGEN3_INCLUDE_DIR}")
    else()
        message(STATUS "Searching for Eigen3 - failed")
    endif()

endif()

if(TARGET blas)
    set(EIGEN3_COMPILER_FLAGS  -Wno-parentheses) # -Wno-parentheses
    set(EIGEN3_USING_BLAS ON)
    if("${CMAKE_CXX_COMPILER_ID}" MATCHES "GNU" )
        list(APPEND EIGEN3_COMPILER_FLAGS -Wno-unused-but-set-variable)
    endif()
    if(TARGET mkl)
        list(APPEND EIGEN3_COMPILER_FLAGS -DEIGEN_USE_MKL_ALL)
        list(APPEND EIGEN3_COMPILER_FLAGS -DEIGEN_USE_LAPACKE_STRICT)
        list(APPEND EIGEN3_INCLUDE_DIR ${MKL_INCLUDE_DIR})
        message(STATUS "Eigen3 will use MKL")
    else ()
        list(APPEND EIGEN3_COMPILER_FLAGS -DEIGEN_USE_BLAS)
        list(APPEND EIGEN3_COMPILER_FLAGS -DEIGEN_USE_LAPACKE_STRICT)
        message(STATUS "Eigen3 will use BLAS and LAPACKE")
    endif()
endif()

if(EIGEN3_FOUND AND TARGET Eigen3::Eigen)
    target_compile_options(Eigen3::Eigen INTERFACE ${EIGEN3_COMPILER_FLAGS})
    target_include_directories(Eigen3::Eigen SYSTEM INTERFACE ${EIGEN3_INCLUDE_DIR})
    add_library(Eigen3 INTERFACE)
    target_link_libraries(Eigen3 INTERFACE Eigen3::Eigen)
    if(TARGET blas)
        target_link_libraries(Eigen3 INTERFACE blas)
    endif()

elseif (DOWNLOAD_LIBS)
    message(STATUS "Eigen3 will be installed into ${INSTALL_DIRECTORY}/Eigen3 on first build.")

    include(ExternalProject)
    ExternalProject_Add(external_EIGEN3
            GIT_REPOSITORY https://github.com/eigenteam/eigen-git-mirror.git
            GIT_TAG 3.3.7
            GIT_PROGRESS false
            GIT_SHALLOW true
            PATCH_COMMAND git apply ${PROJECT_SOURCE_DIR}/cmake-modules/patches/Eigen_3.3.7.patch
            PREFIX      ${BUILD_DIRECTORY}/Eigen3
            INSTALL_DIR ${INSTALL_DIRECTORY}/Eigen3
            CMAKE_ARGS
            -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
            -DCMAKE_INSTALL_MESSAGE=NEVER #Avoid unnecessary output to console, like up-to-date and installing
            UPDATE_COMMAND ""
            TEST_COMMAND ""
#            INSTALL_COMMAND ""
#            CONFIGURE_COMMAND ""
        )


    ExternalProject_Get_Property(external_EIGEN3 INSTALL_DIR)
    add_library(Eigen3 INTERFACE)
    add_library(Eigen3::Eigen ALIAS Eigen3)
    set(EIGEN3_ROOT_DIR ${INSTALL_DIR})
    set(EIGEN3_INCLUDE_DIR ${INSTALL_DIR}/include/eigen3)
    set(Eigen3_DIR ${INSTALL_DIR}/share/eigen3/cmake)
    add_dependencies(Eigen3 external_EIGEN3)
    target_compile_options(Eigen3 INTERFACE ${EIGEN3_COMPILER_FLAGS})
    target_include_directories(Eigen3 SYSTEM INTERFACE ${EIGEN3_INCLUDE_DIR})
    if(TARGET blas)
        target_link_libraries(Eigen3 INTERFACE blas)
    endif()
else()
    message("WARNING: Dependency Eigen3 not found and DOWNLOAD_LIBS is OFF. Build will fail.")
endif()




