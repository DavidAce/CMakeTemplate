
cmake_minimum_required(VERSION 3.24)

### Setup project name and language
project(example07B VERSION 1.2
        DESCRIPTION "Example minimal compilation"
        HOMEPAGE_URL "mycoolwebpage.com"
        LANGUAGES CXX)


### List all source files
add_executable(example07B
        source/cli.cpp
        source/rnd.cpp
        source/main.cpp
        )

# Search the source directory for headers
target_include_directories(example07B PRIVATE source)


### Find dependencies
find_package(h5pp       1.11.1  REQUIRED)
find_package(Eigen3     3.4.0   REQUIRED)
find_package(spdlog     1.13.0  REQUIRED)
find_package(pcg-cpp            REQUIRED)
find_package(CLI11      2.3.2   REQUIRED)
find_package(OpenMP             REQUIRED COMPONENTS CXX)

# Link the libraries to the helper target
target_link_libraries(example07B PRIVATE h5pp::h5pp
                                         Eigen3::Eigen
                                         spdlog::spdlog
                                         pcg-cpp::pcg-cpp
                                         CLI11::CLI11
                                         OpenMP::OpenMP_CXX)
