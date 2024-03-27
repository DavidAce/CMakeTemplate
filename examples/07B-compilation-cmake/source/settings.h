#pragma once
#include <string>

enum class RandDist { NORMAL, UNIFORM };

namespace settings {

    namespace random {
        inline auto seed         = 0ul;
        inline auto distribution = RandDist::NORMAL;
    }

    namespace io {
        inline std::string outfile = "example-06A-simulation.h5";
    }

    namespace log {
        inline long level = 0l;
    }
}