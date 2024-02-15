cmake_minimum_required(VERSION 3.24)
project(example-03E-random-numbers-wow)
add_executable(${PROJECT_NAME} main.cpp rnd.cpp)
target_link_libraries(${PROJECT_NAME} PRIVATE cmt-libs)

