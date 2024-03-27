cmake_minimum_required(VERSION 3.24)
project(example-08A-subsystems)
add_executable(${PROJECT_NAME} main.cpp rnd.cpp cli.cpp)
target_link_libraries(${PROJECT_NAME} PRIVATE cmt-libs)

