project(test-h5pp CXX)
cmake_minimum_required(VERSION 3.10)
set(CMAKE_VERBOSE_MAKEFILE OFF)
add_executable(${PROJECT_NAME} main.cpp )
target_link_libraries(${PROJECT_NAME} PRIVATE project-settings)
target_link_libraries(${PROJECT_NAME} PRIVATE h5pp::h5pp h5pp::deps h5pp::flags)


if(TARGET h5pp::h5pp AND TARGET h5pp::deps AND ENABLE_H5PP)
    get_target_property(H5PP_INFO_INC         h5pp::h5pp   INTERFACE_INCLUDE_DIRECTORIES)
    get_target_property(H5PP_DEPS_LIB         h5pp::deps   INTERFACE_LINK_LIBRARIES)
    get_target_property(H5PP_DEPS_LIB         h5pp::flags  INTERFACE_COMPILE_OPTIONS)
endif()



##################################################################
### Print summary of CMake configuration                       ###
##################################################################
message("=============================================================================")
message("=== SUMMARY OF CMAKE CONFIGURATION:  THE FOLLOWING LIBRARIES WILL BE USED ===")
if(ENABLE_H5PP)
    message("=============================================================================")
    message("    H5PP           INCS :  ${H5PP_INFO_INC}")
    message("                   DEPS :  ${H5PP_DEPS_LIB}")
    message("                   FLAGS:  ${H5PP_DEPS_LIB}")
endif()
message("=============================================================================")
message("")

add_test(NAME test-h5pp COMMAND ${PROJECT_NAME})

