#define ANKERL_NANOBENCH_IMPLEMENT

#include "nanobench.h"
#include <vector>
#include <list>

template<typename Type>
double add_elements_C(uint64_t N) {
    Type *container = (Type *) (malloc(N * sizeof(Type)));  // Allocate memory
    for (uint64_t i = 0; i < N; ++i) container[i] = i;      // Fill with 0,1,2,3...

    double sum = 0;
    for (uint64_t i = 0; i < N; ++i) sum += container[i];

    free(container);                                        // Deallocate memory
    return sum;
}

template<typename Type>
double add_elements_CPP(uint64_t N) {
    Type *container = new Type[N];                          // Allocate memory
    for (uint64_t i = 0; i < N; ++i) container[i] = i;      // Fill with 0,1,2,3...
    double sum = 0;
    for (uint64_t i = 0; i < N; ++i) sum += container[i];
    delete[] container;
    return sum;
}


template<typename Container>
double add_elements_STL(uint64_t N) {
    Container container(N);                           // Initialize a container with N uninitialized elements
    std::iota(container.begin(), container.end(), 0); // Fill with 0,1,2,3...

    double sum = 0;
    for (const auto &elem: container) sum += elem;
    return sum;
}


int main() {

    uint64_t N = 100000;

    auto bench = ankerl::nanobench::Bench().title("Standard Library Containers").warmup(100);

    ankerl::nanobench::Bench().run("add_elements_C: int * (malloc / free)", [&] {
        auto sum = add_elements_C<int>(N);
        ankerl::nanobench::doNotOptimizeAway(sum);
    });

    ankerl::nanobench::Bench().run("add_elements_CPP: int * (new/delete)", [&] {
        auto sum = add_elements_CPP<int>(N);
        ankerl::nanobench::doNotOptimizeAway(sum);
    });

    ankerl::nanobench::Bench().run("add_elements_STL: std::vector<int>", [&] {
        auto sum = add_elements_STL<std::vector<int>>(N);
        ankerl::nanobench::doNotOptimizeAway(sum);
    });
}