#include <fmt/core.h>
#include <random>

int dice_roll_meh(std::mt19937_64 prng) {
    std::uniform_int_distribution<int> dist(0, 6); // Defines an integral uniform distribution [1,6]
    return dist(prng);                             // Rolls the dice
}

int main() {
    std::random_device rd;         // Produces non-deterministic random numbers from hardware if available. Slow, but useful for seeding.
    std::mt19937_64    prng(rd()); // Pseudo-random number generator: 64-bit Mersenne Twister with period 2^19937-1. 2.5 kB internal state (slow, low throughput)

    fmt::print("dice roll 1: {}\n", dice_roll_meh(prng));
    fmt::print("dice roll 2: {}\n", dice_roll_meh(prng));
    fmt::print("dice roll 3: {}\n", dice_roll_meh(prng));
}

// Why are the dice rolls repeated?


































// TODO: no copy/reference
// TODO: determinism
