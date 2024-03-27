cmake_minimum_required(VERSION 3.24)
project(example-09A-raii)
add_executable(${PROJECT_NAME} main.cpp)
target_link_libraries(${PROJECT_NAME} PRIVATE cmt-libs)

