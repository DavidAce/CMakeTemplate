cmake_minimum_required(VERSION 3.24)
project(tests)

if(TARGET h5pp::h5pp)
    list(APPEND TESTS test-h5pp)
endif()

if(TARGET Eigen3::Eigen)
    list(APPEND TESTS test-eigen)
endif()

if(TARGET OpenMP::OpenMP_CXX)
    list(APPEND TESTS test-openmp)
endif()

foreach (test ${TESTS})
    add_executable(${test} ${test}.cpp)
    target_include_directories(${test} PRIVATE ${CMAKE_SOURCE_DIR}/source)
    target_link_libraries(${test} PRIVATE cmt-libs)
    add_test(NAME ${test} WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} COMMAND ${test})
endforeach ()
