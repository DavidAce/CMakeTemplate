function(CheckExperimentalHeaders REQUIRED_FLAGS REQUIRED_LIBRARIES)
    include(CheckIncludeFileCXX)
    set(CMAKE_REQUIRED_FLAGS     "${REQUIRED_FLAGS}" )
    set(CMAKE_REQUIRED_LIBRARIES "${REQUIRED_LIBRARIES}")

    check_include_file_cxx(experimental/filesystem    has_experimental_filesystem  )
    check_include_file_cxx(experimental/type_traits   has_experimental_type_traits )
    if(NOT has_experimental_filesystem OR NOT has_experimental_type_traits )
        message(FATAL_ERROR "\n\
        Missing one or more experimental headers.\n\
        Consider using a newer compiler (GCC 7 or above, Clang 6 or above),\n\
        or checking the compiler flags. If using Clang, pass the variable \n\
        GCC_TOOLCHAIN=<path> \n\
        where path is the install directory of a recent GCC installation (version 7+)
        ")
    endif()

    include(CheckCXXSourceCompiles)
    check_cxx_source_compiles("
    #include <experimental/filesystem>
    #include <experimental/type_traits>
    #include <optional>
    namespace fs = std::experimental::filesystem;

    int main(){
        fs::path testpath;
        std::optional<int> optint;
        return 0;
    }
    " FS_COMPILES)
    if(NOT FS_COMPILES)
        message(FATAL_ERROR "Unable to compile with experimental/filesystem headers")
    endif()
endfunction()