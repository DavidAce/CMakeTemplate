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


















// Comments
//  - Scopes on return statements?
//  - Call function with <type>
//  - What are the benefits of template?
