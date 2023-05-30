
# Print host properties
cmake_host_system_information(RESULT _host_name QUERY HOSTNAME)
cmake_host_system_information(RESULT _proc_type QUERY PROCESSOR_DESCRIPTION)
cmake_host_system_information(RESULT _os_name QUERY OS_NAME)
cmake_host_system_information(RESULT _os_release QUERY OS_RELEASE)
cmake_host_system_information(RESULT _os_version QUERY OS_VERSION)
cmake_host_system_information(RESULT _os_platform QUERY OS_PLATFORM)

message(STATUS "| HOST INFO")
message(STATUS "|---------------------------")
message(DEBUG  "| CMake Version ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}.${CMAKE_PATCH_VERSION}")
message(DEBUG  "| ${_host_name}")
message(STATUS "| ${_os_name} ${_os_platform} ${_os_release}")
message(DEBUG  "| ${_proc_type}")
message(DEBUG  "| ${_os_version}")
message(STATUS "|---------------------------")
