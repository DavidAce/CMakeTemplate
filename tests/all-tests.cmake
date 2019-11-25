##################################################################
### Unit testing                                               ###
##################################################################
if(ENABLE_TESTS)
    enable_testing()

    # Set up a target "all-tests" which will contain all the tests.
    add_custom_target(all-tests)
    # Add the all the tests to all-tests
    if(ENABLE_H5PP)
        add_subdirectory(tests/h5pp EXCLUDE_FROM_ALL)
        add_dependencies(all-tests test-h5pp)  #Make sure the test gets built after main project
    endif()
    if(ENABLE_SPDLOG OR ENABLE_H5PP)
        add_subdirectory(tests/spdlog EXCLUDE_FROM_ALL)
        add_dependencies(all-tests test-spdlog)  #Make sure the test gets built after main project
    endif()
    if(ENABLE_EIGEN3 OR ENABLE_H5PP)
        add_subdirectory(tests/eigen3 EXCLUDE_FROM_ALL)
        add_dependencies(all-tests test-eigen3)  #Make sure the test gets built after main project
    endif()
    if(ENABLE_OPENMP)
        add_subdirectory(tests/openmp EXCLUDE_FROM_ALL)
        add_dependencies(all-tests test-openmp)  #Make sure the test gets built after main project
    endif()

    if(ENABLE_TESTS_POST_BUILD)
        #Run all tests as soon as the tests have been built
        add_custom_command(TARGET all-tests
                POST_BUILD
                COMMENT "Running Tests"
                WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
                COMMAND ${CMAKE_CTEST_COMMAND} -C $<CONFIGURATION> --output-on-failures)

        # Make sure the tests are built and run before building the main project
        add_dependencies(${PROJECT_NAME} all-tests)
    endif()

endif()