cmake_minimum_required(VERSION 3.24)
project(example-04B-read-write-eigen)
add_executable(${PROJECT_NAME} main.cpp)
target_link_libraries(${PROJECT_NAME} PRIVATE cmt-libs)

