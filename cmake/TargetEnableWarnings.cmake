# Turn on warnings on the given target
function(enable_warnings target_name)
    target_compile_options(${target_name} PRIVATE
            $<$<OR:$<CXX_COMPILER_ID:Clang>,$<CXX_COMPILER_ID:AppleClang>,$<CXX_COMPILER_ID:GNU>>:
            -Wall -Wextra -Wconversion -pedantic -Wfatal-errors>
            $<$<CXX_COMPILER_ID:MSVC>:/W4 /WX>)
endfunction()
