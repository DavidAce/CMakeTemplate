cmake_minimum_required(VERSION 3.15)

###  Add optional RELEASE/DEBUG compile to flags
target_compile_options(cmt-flags INTERFACE $<$<AND:$<CONFIG:DEBUG>,$<CXX_COMPILER_ID:Clang>>: -fstandalone-debug>)
target_compile_options(cmt-flags INTERFACE $<$<AND:$<CONFIG:RELWITHDEBINFO>,$<CXX_COMPILER_ID:Clang>>: -fstandalone-debug>)
target_compile_options(cmt-flags INTERFACE
                       $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<CXX_COMPILER_ID:MSVC>>:/W4>
                       $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<NOT:$<CXX_COMPILER_ID:MSVC>>>:-Wall -Wextra -Wpedantic -Wconversion -Wunused>)

# Settings for sanitizers
if(CMT_ENABLE_ASAN)
    target_compile_options(cmt-flags INTERFACE $<$<COMPILE_LANGUAGE:CXX>:-fsanitize=address>) #-fno-omit-frame-pointer
    target_link_libraries(cmt-flags INTERFACE -fsanitize=address)
endif()
if(CMT_ENABLE_USAN)
    target_compile_options(cmt-flags INTERFACE $<$<COMPILE_LANGUAGE:CXX>:-fsanitize=undefined,leak,pointer-compare,pointer-subtract,alignment,bounds -fsanitize-undefined-trap-on-error>) #  -fno-omit-frame-pointer
    target_link_libraries(cmt-flags INTERFACE -fsanitize=undefined,leak,pointer-compare,pointer-subtract,alignment,bounds -fsanitize-undefined-trap-on-error)
endif()

if(CMT_ENABLE_COVERAGE)
    target_compile_options(cmt-flags INTERFACE --coverage)
    target_link_options(cmt-flags INTERFACE --coverage)
endif()
