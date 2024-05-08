#pragma once

#include "cast.h"
#include <algorithm>
#include <cmath>
#include <complex>
#include <exception>
#include <iterator>
#include <numeric>
#include <vector>

#if defined(USE_QUADMATH)
    #include <quadmath.h>
#endif

/*!
 *  \namespace num
 *  \brief Small convenience-type num functions, like modulo
 *  \tableofcontents
 */

namespace num {
#if defined(NDEBUG)
    static constexpr bool ndebug = true;
#else
    static constexpr bool ndebug = false;
#endif
    namespace internal {
        template<typename T>
        struct is_reference_wrapper : std::false_type {};

        template<typename T>
        struct is_reference_wrapper<std::reference_wrapper<T>> : std::true_type {};

        template<typename T>
        inline constexpr bool is_reference_wrapper_v = is_reference_wrapper<T>::value;

    }

    // Safe integer comparison functions from C++20

    template<class T, class U>
    [[nodiscard]] constexpr bool cmp_equal(T t, U u) noexcept {
        if constexpr(internal::is_reference_wrapper_v<T>)
            return cmp_equal(t.get(), u);
        else if constexpr(internal::is_reference_wrapper_v<U>)
            return cmp_equal(t, u.get());
        else if constexpr(std::is_same_v<T, U>)
            return t == u;
        else if constexpr(std::is_floating_point_v<T> and std::is_floating_point_v<U>)
            return t == u;
        else if constexpr(std::is_floating_point_v<T>)
            return static_cast<T>(t) == static_cast<T>(u);
        else if constexpr(std::is_floating_point_v<U>)
            return static_cast<U>(t) == static_cast<U>(u);
        else {
            using UT = std::make_unsigned_t<T>;
            using UU = std::make_unsigned_t<U>;
            if constexpr(std::is_signed_v<T> == std::is_signed_v<U>)
                return t == u;
            else if constexpr(std::is_signed_v<T>)
                return t < 0 ? false : UT(t) == u;
            else
                return u < 0 ? false : t == UU(u);
        }
    }

    template<class T, class U>
    [[nodiscard]] constexpr bool cmp_not_equal(T t, U u) noexcept {
        return !cmp_equal(t, u);
    }

    template<class T, class U>
    [[nodiscard]] constexpr bool cmp_less(T t, U u) noexcept {
        if constexpr(internal::is_reference_wrapper_v<T>)
            return num::cmp_less(t.get(), u);
        else if constexpr(internal::is_reference_wrapper_v<U>)
            return num::cmp_less(t, u.get());
        else if constexpr(std::is_same_v<T, U>)
            return t < u;
        else if constexpr(std::is_floating_point_v<T> and std::is_floating_point_v<U>)
            return t < u;
        else if constexpr(std::is_floating_point_v<T>)
            return static_cast<T>(t) < static_cast<T>(u);
        else if constexpr(std::is_floating_point_v<U>)
            return static_cast<U>(t) < static_cast<U>(u);
        else {
            using UT = std::make_unsigned_t<T>;
            using UU = std::make_unsigned_t<U>;
            if constexpr(std::is_signed_v<T> == std::is_signed_v<U>)
                return t < u;
            else if constexpr(std::is_signed_v<T>)
                return t < 0 ? true : UT(t) < u;
            else
                return u < 0 ? false : t < UU(u);
        }
    }

    template<class T, class U>
    [[nodiscard]] constexpr bool cmp_greater(T t, U u) noexcept {
        return num::cmp_less(u, t);
    }

    template<class T, class U>
    [[nodiscard]] constexpr bool cmp_less_equal(T t, U u) noexcept {
        return !num::cmp_greater(t, u);
    }

    template<class T, class U>
    [[nodiscard]] constexpr bool cmp_greater_equal(T t, U u) noexcept {
        return !num::cmp_less(t, u);
    }

    template<typename out_t, typename ContainerT, typename Func>
    std::vector<out_t> cast(const ContainerT &x, Func &&f) {
        std::vector<out_t> y;
        std::transform(x.data(), x.data() + x.size(), std::back_inserter(y), std::forward<Func>(f));
        return y;
    }

    /*! \brief MatLab-style modulo operator
     *   \param x first number
     *   \param y second number
     *   \return modulo of x and y. Example, <code> mod(7,2)  = 1 </code> but <code> mod(-0.5,10)  = 9.5 </code>, instead of <code> -0.5 </code>  as given by
     * x%y.
     */
    template<typename T>
    [[nodiscard]] inline T mod(const T x, const T y) {
        if constexpr(!ndebug)
            if(y == 0) throw std::logic_error("num::mod(x,y): divisor y == 0");
        if constexpr(std::is_integral_v<T>) {
            if constexpr(std::is_unsigned_v<T>)
                return x >= y ? x % y : x;
            else { return x >= y ? x % y : (x < 0 ? (x % y + y) % y : x); }

        }
        //            return (x % y + y) % y;
        else
            return std::fmod((std::fmod(x, y) + y), y);
    }

    /*! \brief Similar to mod but faster for use with periodic boundary condition
     *   \param x first number
     *   \param y second number
     *   \return modulo of x and y. Example, <code> mod(7,2)  = 1 </code> but <code> mod(-0.5,10)  = 9.5 </code>, instead of <code> -0.5 </code>  as given by
     * x%y.
     */
    template<typename T>
    [[nodiscard]] inline T pbc(const T x, const T y) {
        if constexpr(!ndebug)
            if(y == 0) throw std::logic_error("num::pbc(x,y): divisor y == 0");
        if constexpr(std::is_signed_v<T>) {
            if(x >= 0 and x < y) return x;
            if(x < 0 and x >= -2 * y) return x + y;
        } else {
            if(x < y) return x;
        }
        if(x >= y and x < 2 * y) return x - y;
        return num::mod(x, y);
    }

    template<typename T>
    [[nodiscard]] int sign(const T val) noexcept {
        if(val > 0) return +1;
        if(val < 0) return -1;
        return 0;
    }

    template<typename T>
    [[nodiscard]] bool between(const T &value, const T &low, const T &high) noexcept {
        return value >= low and value <= high;
    }

    /*! \brief Python-style range generator, i.e. not-including "last"
     *   \return Range of T's. Example, <code> range(0,8,2) </code> gives a std::vector<int>: <code> [0,2,4,6] </code>
     */
    namespace internal {
        template<typename TA, typename TB>
        using int_or_dbl = typename std::conditional<std::is_floating_point_v<TA> or std::is_floating_point_v<TB>, double, int>::type;
    }

    template<typename T = int, typename T1, typename T2, typename T3 = internal::int_or_dbl<T1, T2>>
    [[nodiscard]] std::vector<T> range(T1 first, T2 last, T3 step = static_cast<T3>(1)) noexcept {
        if(step == 0) return {static_cast<T>(first)};
        auto num_steps =
            safe_cast<size_t>(std::abs((static_cast<double>(last) - static_cast<double>(first) + static_cast<double>(step)) / static_cast<double>(step)));
        std::vector<T> vec;
        vec.reserve(num_steps);
        auto val = static_cast<T>(first);
        if(num::cmp_less(first, last)) {
            while(num::cmp_less(val, last)) {
                vec.emplace_back(val);
                val += num::cmp_less(step, 0) ? -static_cast<T>(step) : static_cast<T>(step);
            }
        } else {
            while(num::cmp_greater(val, last)) {
                vec.emplace_back(val);
                val -= num::cmp_less(step, 0) ? -static_cast<T>(step) : static_cast<T>(step);
            }
        }
        if constexpr(std::is_signed_v<T3>) {
            if(step < 0) return {vec.rbegin(), vec.rend()};
        }
        return vec;
    }

    /*! \brief MatLab-style linearly spaced array
     *   \param num number of linearly spaced values
     *   \param a first value in range
     *   \param b last value in range
     *   \return std::vector<T2>. Example,  <code> Linspaced(5,1,5) </code> gives a std::vector<int>: <code> [1,2,3,4,5] </code>
     */
    template<typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
    [[nodiscard]] inline std::vector<T> LinSpaced(std::size_t N, T a, T b) {
        static_assert(std::is_floating_point_v<T>);
        T              h   = (b - a) / static_cast<T>(N - 1);
        T              val = a;
        std::vector<T> xs(N);
        for(auto &x : xs) {
            x = val;
            val += h;
        }
        xs.front() = a;
        xs.back()  = b;
        return xs;
    }

    template<typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
    [[nodiscard]] inline std::vector<T> LogSpaced(std::size_t N, T a, T b, int base = 10, int keep_digits = -1) {
        static_assert(std::is_floating_point_v<T>);
        if(a <= 0) throw std::range_error("a must be positive");
        if(b <= 0) throw std::range_error("b must be positive");
        T              baseT  = static_cast<T>(base);
        T              loga   = std::log(a) / std::log(baseT);
        T              logb   = std::log(b) / std::log(baseT);
        T              h      = (logb - loga) / static_cast<T>(N - 1);
        T              factor = std::pow(baseT, h);
        T              val    = std::pow(baseT, loga);
        std::vector<T> xs(N);
        for(auto &x : xs) {
            x   = val;
            T s = std::ceil(std::log10(x)); // Base 10 exponent of x
            if(keep_digits > 0 and s > keep_digits) {
                T t = std::pow(static_cast<T>(10), s - keep_digits); // Order of magnitude to truncate
                x   = std::floor(x / t) * t;
            }
            if(std::isnan(x) or std::isinf(x)) throw std::logic_error("Invalid value in logspaced");
            val *= factor;
        }
        xs.front() = a;
        xs.back()  = b;
        return xs;
    }

#if defined(USE_QUADMATH)
    template<typename T, std::enable_if_t<std::is_same_v<T, __float128>, bool> = true>
    [[nodiscard]] inline std::vector<T> LinSpaced(std::size_t N, T a, T b) {
        T              h   = (b - a) / static_cast<T>(N - 1);
        T              val = a;
        std::vector<T> xs(N);
        for(auto &x : xs) {
            x = val;
            val += h;
        }
        xs.front() = a;
        xs.back()  = b;
        return xs;
    }

    template<typename T, std::enable_if_t<std::is_same_v<T, __float128>, bool> = true>
    [[nodiscard]] inline std::vector<T> LogSpaced(std::size_t N, T a, T b, int base = 10, int keep_digits = -1) {
        if(a <= 0) throw std::range_error("a must be positive");
        if(b <= 0) throw std::range_error("b must be positive");
        T              baseT  = static_cast<T>(base);
        T              loga   = logq(a) / logq(baseT);
        T              logb   = logq(b) / logq(baseT);
        T              h      = (logb - loga) / static_cast<T>(N - 1);
        T              factor = powq(baseT, h);
        T              val    = powq(baseT, loga);
        std::vector<T> xs(N);
        for(auto &x : xs) {
            x   = val;
            T s = ceilq(log10q(x)); // Base 10 exponent of x
            if(keep_digits > 0 and s > keep_digits) {
                T t = powq(static_cast<T>(10), s - keep_digits); // Order of magnitude to truncate
                x   = floorq(x / t) * t;
            }
            val *= factor;
        }
        xs.front() = a;
        xs.back()  = b;
        return xs;
    }
#endif

    /*! \brief Sum operator for containers such as vector
     *   \param in a vector, array or any 1D container with "<code> .data() </code>" method.
     *   \param from first element to add (default == 0)
     *   \param to last element to add (default == -1: from - size)
     *   \return sum of of elements with type Input::value_type .
     *   \example Let <code> v = {1,2,3,4}</code>. Then <code> sum(v,0,3) = 10 </code>.
     */
    template<typename Input>
    [[nodiscard]] auto sum(const Input &in, size_t from = 0, size_t num = -1ul) {
        if(num == -1ul) num = in.size();
        num = std::min<size_t>(num, static_cast<size_t>(in.size()) - from);
        return std::accumulate(std::begin(in) + safe_cast<long>(from), std::begin(in) + safe_cast<long>(from + num),
                               static_cast<typename Input::value_type>(0));
    }

    /*! \brief Product operator for containers such as vector
     *   \param in a vector, array or any 1D container with "<code> .data() </code>" method.
     *   \param from first element to multiply (default == 0)
     *   \param to last element to multiply (default == -1: from - size)
     *   \return product of of elements with type Input::value_type .
     *   \example Let <code> v = {1,2,3,4}</code>. Then <code> prod(v,0,3) = 24 </code>.
     */
    template<typename Input>
    [[nodiscard]] auto prod(const Input &in, size_t from = 0, size_t num = -1ul) {
        from = std::clamp<size_t>(from, 0, in.size());
        num  = std::clamp<size_t>(num, 0, in.size() - from);
        return std::accumulate(std::begin(in) + safe_cast<long>(from), std::begin(in) + safe_cast<long>(from + num), 1, std::multiplies<>());
    }
    template<typename Input>
    [[nodiscard]] auto diff(const Input &in, size_t from = 0, size_t num = -1ul) {
        from = std::clamp<size_t>(from, 0, in.size());
        num  = std::clamp<size_t>(num, 0, in.size() - from);
        if constexpr(std::is_default_constructible_v<Input>) {
            Input res;
            res.reserve(num);
            std::adjacent_difference(std::begin(in) + safe_cast<long>(from), std::begin(in) + safe_cast<long>(from + num), std::back_inserter(res));
            return res;
        } else {
            using value_type = typename Input::value_type;
            std::vector<value_type> res;
            res.reserve(num);
            std::adjacent_difference(std::begin(in) + safe_cast<long>(from), std::begin(in) + safe_cast<long>(from + num), std::back_inserter(res));
            return res;
        }
    }

    /*! \brief Cumulative operator for containers such as vector
     *   \param in a vector, array or any 1D container with "<code> .data() </code>" method.
     *   \param from first element to add (default == 0)
     *   \param to last element to add (default == -1: from - size)
     *   \return binary op of of elements with type Input::value_type .
     *   \example Let <code> v = {1,2,3,4}</code>. Then <code> cumop(v,std::plus<>(),0,3) = {1,3,6,10} </code>.
     */
    template<typename Input, typename BinaryOp>
    [[nodiscard]] Input cumop(const Input &in, BinaryOp op, size_t from = 0, size_t num = -1ul) {
        Input res;
        from = std::clamp<size_t>(from, 0, in.size());
        num  = std::clamp<size_t>(num, 0, in.size());
        std::partial_sum(in.begin() + safe_cast<long>(from), in.begin() + safe_cast<long>(from + num), std::back_inserter(res), op);
        return res;
    }

    template<typename Input>
    [[nodiscard]] Input cumsum(const Input &in, size_t from = 0, size_t num = -1ul) {
        return cumop(in, std::plus<typename Input::value_type>(), from, num);
    }
    template<typename Input>
    [[nodiscard]] Input cumsub(const Input &in, size_t from = 0, size_t num = -1ul) {
        return cumop(in, std::minus<typename Input::value_type>(), from, num);
    }
    template<typename Input>
    [[nodiscard]] Input cumprod(const Input &in, size_t from = 0, size_t num = -1ul) {
        return cumop(in, std::multiplies<typename Input::value_type>(), from, num);
    }
    template<typename Input>
    [[nodiscard]] Input cummin(const Input &in, size_t from = 0, size_t num = -1ul) {
        return cumop(in, [](auto a, auto b) { return std::min(a, b); }, from, num);
    }
    template<typename Input>
    [[nodiscard]] Input cummax(const Input &in, size_t from = 0, size_t num = -1ul) {
        return cumop(in, [](auto a, auto b) { return std::max(a, b); }, from, num);
    }

    /*! \brief Trapezoidal rule for numerical integration
     *   \param X a vector-like container
     *   \param Y a vector-like container
     *   \param from first element to multiply (default == 0)
     *   \param to last element to multiply (default == -1: from - size)
     *   \return product of of elements with type Input::value_type .
     *   \example Let <code> v = {1,2,3,4}</code>. Then <code> prod(v,0,3) = 24 </code>.
     */
    template<typename ContainerType1, typename ContainerType2>
    double trapz(const ContainerType1 &X, const ContainerType2 &Y, long from = 0, long num = -1) {
        auto   xfrm = std::clamp<long>(from, 0, safe_cast<long>(X.size()));
        auto   yfrm = std::clamp<long>(from, 0, safe_cast<long>(Y.size()));
        auto   xnum = std::clamp<long>(num, xfrm, safe_cast<long>(X.size()));
        auto   ynum = std::clamp<long>(num, yfrm, safe_cast<long>(Y.size()));
        auto   x_it = X.begin() + from;
        auto   y_it = Y.begin() + from;
        auto   x_en = X.begin() + xnum;
        auto   y_en = Y.begin() + ynum;
        double res  = 0.0;
        while(x_it != x_en and y_it != y_en) {
            auto x_nx = std::next(x_it);
            auto y_nx = std::next(y_it);
            if(x_nx == x_en) break;
            if(y_nx == y_en) break;
            res += (*x_nx - *x_it) * 0.5 * (*y_nx + *y_it);
            x_it++;
            y_it++;
        }
        return res;
    }

    /*! \brief Checks if multiple values are equal to each other
     *   \param args any number of values
     *   \return bool, true if all args are equal
     */
    template<typename First, typename... T>
    [[nodiscard]] bool all_equal(First &&first, T &&...t) noexcept {
        return ((first == t) && ...);
    }

    template<typename R, typename T>
    [[nodiscard]] R next_power_of_two(T val) {
        return static_cast<R>(std::pow<long>(2, safe_cast<long>(std::ceil(std::log2(std::real(val))))));
    }
    template<typename R, typename T>
    [[nodiscard]] R prev_power_of_two(T val) {
        return static_cast<R>(std::pow<long>(2, safe_cast<long>(std::floor(std::log2(std::real(val - 1))))));
    }
    template<typename R, typename T>
    [[nodiscard]] R nearest_power_of_two(T val) {
        auto next2 = next_power_of_two<R>(val);
        auto prev2 = prev_power_of_two<R>(val);
        if(std::abs(val - next2) < std::abs(val - prev2))
            return next2;
        else
            return prev2;
    }

    template<typename R, typename T>
    [[nodiscard]] inline R next_multiple(const T num, const T mult) {
        if(mult == 0) return num;
        return (num + mult) - mod(num, mult);
    }
    template<typename R, typename T>
    [[nodiscard]] inline R prev_multiple(const T num, const T mult) {
        if(mult == 0) return num;
        auto m = mod(num, mult);
        if(m == 0) return prev_multiple<R>(num - 1, mult);
        return num - m;
    }

    template<typename T>
    [[nodiscard]] inline T round_to_multiple_of(const T number, const T multiple) {
        T result = number + multiple / 2;
        result -= num::mod(result, multiple);
        return result;
    }

    template<typename T>
    [[nodiscard]] inline T round_up_to_multiple_of(const T number, const T multiple) {
        if(multiple == 0) return number;
        auto remainder = num::mod(std::abs(number), multiple);
        if(remainder == 0) return number;
        if(number < 0)
            return -(std::abs(number) - remainder);
        else
            return number + multiple - remainder;
    }
}
