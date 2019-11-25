set(CMAKE_SYSTEM_NAME Linux)

set(CMAKE_C_COMPILER   clang)
set(CMAKE_CXX_COMPILER clang++)

#set(COMMON_OPTIONS                    -g -Wall -Wpedantic -Wextra  -march=${MARCH} -mtune=${MARCH})
set(CMAKE_CXX_FLAG)
set(CMAKE_CXX_FLAGS_RELEASE           -O3 -DNDEBUG)
set(CMAKE_CXX_FLAGS_DEBUG             -O0 -g3 -fstack-protector -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC -D_FORTIFY_SOURCE=2 -Wall -Wpedantic -Wextra )
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO    -O1 -g3 -fstack-protector -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC -D_FORTIFY_SOURCE=2)

#set(COMMON_OPTIONS            -g -Wall -Wpedantic -Wextra  -march=${MARCH} -mtune=${MARCH})
#set(DEBUG_OPTIONS             -O0 -g3 -fstack-protector -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC -D_FORTIFY_SOURCE=2)
#set(RELWITHDEBINFO_OPTIONS    -O1 -g3 -fstack-protector -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC -D_FORTIFY_SOURCE=2)
#set(RELEASE_OPTIONS           -O3 -DNDEBUG )
#set(PROFILE_OPTIONS           -O3 -DNDEBUG  -lprofiler -g  -ftime-report)
