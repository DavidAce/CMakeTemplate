cmake_minimum_required(VERSION 3.12)
project(tests)
add_custom_target(all-tests)
if(TARGET h5pp::h5pp OR TARGET CONAN_PKG::h5pp)
    list(APPEND TESTS test-h5pp)
endif()

if(TARGET Eigen3::Eigen OR TARGET CONAN_PKG::eigen)
    list(APPEND TESTS test-eigen)
endif()

if(TARGET openmp::openmp)
    list(APPEND TESTS test-openmp)
endif()


foreach (test ${TESTS})
    add_executable(${test} ${test}.cpp)
    set_target_properties(${test} PROPERTIES LINK_WHAT_YOU_USE TRUE)
    target_include_directories(${test} PRIVATE ${CMAKE_SOURCE_DIR}/source)
    target_link_libraries(${test} PRIVATE cmt-settings)

    add_test(NAME ${test} WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} COMMAND ${test})
    if (MSVC)
        set_target_properties(${test} PROPERTIES LINK_FLAGS "/ignore:4099")
    endif()
    add_dependencies(all-tests ${test})
endforeach ()

add_custom_command(
        TARGET all-tests
        POST_BUILD
        COMMENT "Running Tests"
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        DEPENDS CMT
        COMMAND ${CMAKE_CTEST_COMMAND} -C $<CONFIG> --output-on-failure)



# Speed up compilation with precompiled headers
if(CMT_ENABLE_PCH)
    if(COMMAND target_precompile_headers)
        foreach (test ${TESTS})
            if(NOT TARGET ${first_tgt})
                target_precompile_headers(${test} PRIVATE <string> <vector> <array> <optional> <memory>)
                set(first_test ${test})
            else()
                target_precompile_headers(${test} REUSE_FROM ${first_test})
            endif()
        endforeach()
    endif()
endif()

# Speed up compilation with ccache
if(CMT_ENABLE_CCACHE)
    find_program(CCACHE_PROGRAM ccache)
    if(CCACHE_PROGRAM)
        foreach (test ${TESTS})
            set_target_properties(${test} PROPERTIES CXX_COMPILER_LAUNCHER ${CCACHE_PROGRAM})
        endforeach()
        message(STATUS "Tests using ccache ${CCACHE_PROGRAM}")
        if(CMT_ENABLE_PCH AND COMMAND target_precompile_headers)
            message(STATUS "Detected ccache + pch: Remember to set --> sloppiness = include_file_mtime,pch_defines,time_macros <-- in your ccache.conf")
        endif()
    else()
        message(STATUS "ccache program could not be found")
    endif()
endif()

