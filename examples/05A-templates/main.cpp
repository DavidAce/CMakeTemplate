#include <fmt/core.h>

template<typename T>
T min(T a, T b) {
    if(a < b)
        return a;
    else
        return b;
}

int main() {
    auto a = 5;
    auto b = 4;
    fmt::print("min({},{}) = {}", a,b, min(a,b));
}


// What is the type of T?















// Comments
//  - Scopes on return statements?
//  - Call function with <type>
//  - What are the benefits of templates?
//      - Code reuse
//      - Run time costs move to compile time
//      -
//   - What are the drawbacks of templates?
//   - Compilation time increases (if not careful)

