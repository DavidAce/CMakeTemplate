project(test-spdlog CXX)
cmake_minimum_required(VERSION 3.10)
set(CMAKE_VERBOSE_MAKEFILE OFF)
add_executable(${PROJECT_NAME} logger.h  main.cpp  logger.cpp logger.h  )
target_link_libraries(${PROJECT_NAME} PRIVATE project-settings)
target_link_libraries(${PROJECT_NAME} PRIVATE spdlog::spdlog)
add_test(NAME test-spdlog COMMAND ${PROJECT_NAME})

