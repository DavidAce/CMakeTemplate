

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
set(CMAKE_CXX_FLAGS_DEBUG_INIT          "-O0 -g3 -fstack-protector -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC -D_FORTIFY_SOURCE=2 -Wall -Wpedantic -Wextra")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT "-O1 -march=native -mtune=native -g3 -fstack-protector -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC -D_FORTIFY_SOURCE=2 -Wall -Wpedantic -Wextra")
set(CMAKE_CXX_FLAGS_RELEASE_INIT        "-O3 -march=native -mtune=native -DNDEBUG ")
endif()