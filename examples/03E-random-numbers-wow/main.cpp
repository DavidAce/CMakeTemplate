#include <fmt/core.h>
#include "rnd.h"


int main() {
    rnd::seed(42);
    fmt::print("dice roll 1: {}\n", rnd::uniform(1,6));
    fmt::print("dice roll 2: {}\n", rnd::uniform(1,6));
    fmt::print("dice roll 3: {}\n", rnd::uniform(1,6));
}



// What happens with other types?



































