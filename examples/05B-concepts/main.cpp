#include <fmt/core.h>
#include "concepts.h"



template<typename T>
requires is_arithmetic_v<T>
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
// Static assert?
//
