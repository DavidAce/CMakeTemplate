#pragma once
#include <string>

enum class RandDist { NORMAL, UNIFORM };

namespace settings {

    namespace model {
        inline long Lx = 25;
        inline long Ly = 25;
    }
    namespace random {
        inline auto seed         = 0ul;
        inline auto distribution = RandDist::NORMAL;
    }

    namespace io {
        inline std::string outfile = "example-08A-subsystems.h5";
    }

    namespace log {
        inline long level = 2l;
    }
}