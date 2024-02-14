#define ANKERL_NANOBENCH_IMPLEMENT

#include "nanobench.h"
#include <vector>
#include <list>

template<typename Container>
double add_elements_A(uint64_t N) {
    Container container;                                         // Initialize an empty container
    for (uint64_t i = 0; i < N; ++i) container.emplace_back(i);  // Append 0,1,2,3...
    double sum = 0;
    for (const auto &elem: container) sum += elem;
    return sum;
}


template<typename Container>
double add_elements_B(uint64_t N) {
    Container container(N);                           // Initialize a container with N uninitialized elements
    std::iota(container.begin(), container.end(), 0); // Fill with 0,1,2,3...

    double sum = 0;
    for (const auto &elem: container) sum += elem;
    return sum;
}



int main() {

    uint64_t N = 100000;

    auto bench = ankerl::nanobench::Bench().title("Standard Library Containers").relative(true).epochs(
            10000).minEpochIterations(10000);
    ankerl::nanobench::Bench().run("add_elements_A: std::vector<int>", [&] {
        auto sum = add_elements_A<std::vector<int>>(N);
        ankerl::nanobench::doNotOptimizeAway(sum);
    });

    ankerl::nanobench::Bench().run("add_elements_B: std::vector<int>", [&] {
        auto sum = add_elements_B<std::vector<int>>(N);
        ankerl::nanobench::doNotOptimizeAway(sum);
    });
}