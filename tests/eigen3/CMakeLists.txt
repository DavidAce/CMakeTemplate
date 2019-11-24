project(test-eigen3 CXX)
cmake_minimum_required(VERSION 3.10)
set(CMAKE_VERBOSE_MAKEFILE OFF)
add_executable(${PROJECT_NAME} main.cpp )
target_link_libraries(${PROJECT_NAME} PRIVATE project-settings)
if(TARGET h5pp::eigen3)
    target_link_libraries(${PROJECT_NAME} PRIVATE h5pp::eigen3)
else()
    target_link_libraries(${PROJECT_NAME} PRIVATE Eigen3::Eigen)
endif()

add_test(NAME test-eigen3 COMMAND ${PROJECT_NAME})

