#include <cstdlib>
#include <fmt/core.h>

// READ: https://en.cppreference.com/w/cpp/numeric/random/rand
int thou_shall_not_seed_srand(int seed = 666) {
    std::srand(seed);                                            // Seed (stahp!)
    int random_value = std::rand();                              // Random integer between 0 and RAND_MAX=2147483647 (same as INT_MAX) (Noooooo!)
    int dice_value   = 1 + random_value / ((RAND_MAX + 1u) / 6); // Map to [1,6]  (╥﹏╥)
    return dice_value;
}

int main() {
    fmt::print("dice roll 1: {}\n", thou_shall_not_seed_srand());
    fmt::print("dice roll 2: {}\n", thou_shall_not_seed_srand());
    fmt::print("dice roll 3: {}\n", thou_shall_not_seed_srand());
}
































// TODO: uniform? quality of random numbers?
// TODO: thread safety?
// TODO: what happens for other integral types?
