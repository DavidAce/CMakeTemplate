#include "cli.h"
#include "log.h"
#include "settings.h"
#include <fmt/core.h>
#include <unsupported/Eigen/CXX11/Tensor>

template<typename T, size_t N>
constexpr std::array<T, N> operator+(const std::array<T, N> &a1, const std::array<T, N> &a2) {
    std::array<T, N> res = {};
    for(size_t i = 0; i < N; ++i) res[i] = a1[i] + a2[i];
    return res;
}

double get_safe_value(const Eigen::Tensor<double, 4> &SvN, const std::array<long, 4> &indices) {
    for(size_t i = 0; i < indices.size(); ++i)
        if(indices[i] < 0 or indices[i] >= SvN.dimension(i)) return 0;
    return SvN(indices);
}

double get_subsystem_information(const Eigen::Tensor<double, 4> &SvN, const std::array<long, 4> &indices) {
    static constexpr auto i0000 = std::array<long, 4>{0, 0, 0, 0};
    static constexpr auto i0001 = std::array<long, 4>{0, 0, 0, 1};
    static constexpr auto i0010 = std::array<long, 4>{0, 0, 1, 0};
    static constexpr auto i0011 = std::array<long, 4>{0, 0, 1, 1};
    static constexpr auto i0100 = std::array<long, 4>{0, 1, 0, 0};
    static constexpr auto i0101 = std::array<long, 4>{0, 1, 0, 1};
    static constexpr auto i0111 = std::array<long, 4>{0, 1, 1, 1};
    static constexpr auto i1000 = std::array<long, 4>{1, 0, 0, 0};
    static constexpr auto i1001 = std::array<long, 4>{1, 0, 0, 1};
    static constexpr auto i1010 = std::array<long, 4>{1, 0, 1, 0};
    static constexpr auto i1011 = std::array<long, 4>{1, 0, 1, 1};
    static constexpr auto i1100 = std::array<long, 4>{1, 1, 0, 0};
    static constexpr auto i1101 = std::array<long, 4>{1, 1, 0, 1};
    static constexpr auto i1111 = std::array<long, 4>{1, 1, 1, 1};

    return get_safe_value(SvN, indices + i0000) + //
           get_safe_value(SvN, indices + i0001) - //
           get_safe_value(SvN, indices + i0010) + //
           get_safe_value(SvN, indices + i0011) - //
           get_safe_value(SvN, indices + i0100) + //
           get_safe_value(SvN, indices + i0101) - //
           get_safe_value(SvN, indices + i0111) + //
           get_safe_value(SvN, indices + i1000) - //
           get_safe_value(SvN, indices + i1001) + //
           get_safe_value(SvN, indices + i1010) - //
           get_safe_value(SvN, indices + i1011) + //
           get_safe_value(SvN, indices + i1100) - //
           get_safe_value(SvN, indices + i1101) + //
           get_safe_value(SvN, indices + i1111);
}

int main(int argc, char *argv[]) {
    cli::parse(argc, argv);
    using namespace settings::model;

    auto SvN = Eigen::Tensor<double, 4>(Lx, Ly, Lx, Ly);
    SvN.setRandom();

    auto SSI = Eigen::Tensor<double,4>(Lx, Ly, Lx, Ly);
    for(long lx = 0; lx < Lx; ++lx)
        for(long ly = 0; ly < Ly; ++ly)
            for(long ix = 0; ix < Lx; ++ix)
                for(long iy = 0; iy < Ly; ++iy)
                    SSI(lx,ly,ix,iy) = get_subsystem_information(SvN, std::array{lx,ly,ix,iy});


    logger::log->info("subsystem information  0, 0, 0, 0: {}", SSI(0,0,0,0));
}
