#include "concepts.h"
#include <fmt/core.h>

template<typename T>
requires is_arithmetic_v<T> || has_imag_v<T>
T min(T a, T b) {
    if constexpr(is_arithmetic_v<T>) {
        if(a < b)
            return a;
        else
            return b;
    } else if constexpr(has_imag_v<T>) {
        if(a.real() < b.real())
            return a;
        else
            return b;
    }
}

int main() {
    auto a = 5;
    auto b = 4;
    fmt::print("min({},{}) = {}", a, b, min(a, b));
}

// Comments
// Static assert?
//
