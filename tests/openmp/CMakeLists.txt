project(test-openmp CXX)
cmake_minimum_required(VERSION 3.10)
add_executable(${PROJECT_NAME} main.cpp)
target_link_libraries(${PROJECT_NAME} PRIVATE project-settings)
add_test(NAME test-openmp COMMAND ${PROJECT_NAME})

