##################################################################
### Print operating system details                          ###
##################################################################
cmake_host_system_information(RESULT _host_name QUERY HOSTNAME)
set(GET_OS_INFO_CMD lsb_release -a)
if(${CMAKE_HOST_APPLE})
    set(GET_OS_INFO_CMD "sw_vers")
endif()
execute_process(COMMAND ${GET_OS_INFO_CMD}
        OUTPUT_VARIABLE OS_DETAILS
        OUTPUT_STRIP_TRAILING_WHITESPACE)
message("========= DETECTED OS =========")
message("Hostname: " ${_host_name})
message("${OS_DETAILS}")
message("===============================")
