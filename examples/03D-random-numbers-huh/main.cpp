#include <fmt/core.h>
#include <random>

template<typename NumType, typename PrngType>
auto dice_roll_huh(NumType min, NumType max, PrngType &prng) {
    std::uniform_int_distribution<NumType> dist(min, max); // Defines an integral uniform distribution [1,6]
    return dist(prng);
}

int main() {
    std::random_device rd;         // Produces non-deterministic random numbers from hardware if available. Slow, but useful for seeding.
    std::mt19937_64    prng(rd()); // Produces a random number generator initialized by a seed
    fmt::print("dice roll 1: {}\n", dice_roll_huh(0,6,prng));
    fmt::print("dice roll 2: {}\n", dice_roll_huh(0,6,prng));
    fmt::print("dice roll 3: {}\n", dice_roll_huh(0,6,prng));
}

























// TODO: What happens if we use floating point types?
