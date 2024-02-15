cmake_minimum_required(VERSION 3.24)
project(example-02A-linear-algebra)
add_executable(${PROJECT_NAME} main.cpp)
target_link_libraries(${PROJECT_NAME} PRIVATE cmt-libs)

