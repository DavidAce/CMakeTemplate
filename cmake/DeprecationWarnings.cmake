
if(CMT_DOWNLOAD_METHOD)
    message(WARNING "The following CMake variable has been deprecated\n"
            "\t CMT_DOWNLOAD_METHOD=[none|find|fetch|find-or-fetch|conan]\n"
            "Update this variable to\n"
            "\t CMT_PACKAGE_MANAGER=[find|cmake|find-or-cmake|conan]")
endif()