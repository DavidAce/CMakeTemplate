#pragma once

#include <stdexcept>
#include <type_traits>
#include <utility>

template<typename To, typename From>
    requires std::is_arithmetic_v<std::remove_cvref_t<To>> && std::is_arithmetic_v<std::remove_cvref_t<From>>
inline To
#if defined(NDEBUG)
    safe_cast(From f) noexcept {
    return static_cast<To>(f);
}
#else
    safe_cast(From f) {
    if constexpr(std::integral<To> && std::integral<From>) {
        auto constexpr tmin = std::numeric_limits<To>::min();
        auto constexpr fmin = std::numeric_limits<From>::min();
        auto constexpr tmax = std::numeric_limits<To>::max();
        auto constexpr fmax = std::numeric_limits<From>::max();
        if constexpr(std::cmp_greater_equal(tmin, fmin) and std::cmp_less_equal(tmax, fmax)) return static_cast<To>(f);
        if(!std::in_range<To>(f)) throw std::runtime_error("integral to integral cast out of range");
    }
    if constexpr(std::integral<To> && std::floating_point<From>) { // Cast from floating point to integral
        auto constexpr tmin = std::numeric_limits<To>::min();
        auto constexpr tmax = std::numeric_limits<To>::max();
        if(f > static_cast<From>(tmax) or f < static_cast<From>(tmin)) throw std::runtime_error("floating point to integral cast out of range");
    }
    return static_cast<To>(f);
}
#endif
