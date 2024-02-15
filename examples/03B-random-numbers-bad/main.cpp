#include <fmt/core.h>
#include <random>

int dice_roll_bad() {
    std::random_device                 rd;         // Produces non-deterministic random numbers from hardware if available. Slow, but useful for seeding.
    std::uniform_int_distribution<int> dist(0, 6); // Defines an integral uniform distribution [1,6]
    return dist(rd);                               // Rolls the dice
}

int main() {
    fmt::print("dice roll 1: {}\n", dice_roll_bad());
    fmt::print("dice roll 2: {}\n", dice_roll_bad());
    fmt::print("dice roll 3: {}\n", dice_roll_bad());
}



































// TODO: entropy source? rand? hardware?
// TODO: how about std::time?
// TODO: determinism
