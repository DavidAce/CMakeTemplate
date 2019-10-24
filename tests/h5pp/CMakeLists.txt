project(test-h5pp CXX)
cmake_minimum_required(VERSION 3.10)
set(CMAKE_VERBOSE_MAKEFILE OFF)
add_executable(${PROJECT_NAME} main.cpp )
target_link_libraries(${PROJECT_NAME} PRIVATE project-settings)
target_link_libraries(${PROJECT_NAME} PRIVATE h5pp::h5pp h5pp::deps)
add_test(NAME test-h5pp COMMAND ${PROJECT_NAME})

