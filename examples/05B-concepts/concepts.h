#pragma once
#include <type_traits>
#include <concepts>

template<typename T>
concept is_arithmetic_v = std::integral<std::remove_cvref_t<T>> or std::floating_point<std::remove_cvref_t<T>>;

template<typename T>
concept has_imag_v = requires(T m) {
    { m.imag() } -> is_arithmetic_v;
};
