//
// Created by david on 2024-02-28.
//
#include "rnd.h"

void rnd::seed(std::optional<uint64_t> number) {
    if(number.has_value()) {
        pcg_extras::seed_seq_from<pcg64> seq(number.value());
        internal::prng.seed(seq);
    }
}