project(test-eigen3 CXX)
cmake_minimum_required(VERSION 3.12)
set(CMAKE_VERBOSE_MAKEFILE OFF)
add_executable(${PROJECT_NAME} main.cpp )
target_link_libraries(${PROJECT_NAME} PRIVATE project-settings)
add_test(NAME test-eigen3 COMMAND ${PROJECT_NAME})

