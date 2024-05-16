#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN

#include <doctest/doctest.h>
#include <h5pp/h5pp.h>

template<typename T>
T write_then_read(const T &item) {
    auto f = h5pp::File("test-h5pp.h5", h5pp::FileAccess::REPLACE);
    f.writeDataset(item, h5pp::type::sfinae::type_name<T>());
    return f.readDataset<T>(h5pp::type::sfinae::type_name<T>());
}

TEST_CASE("write/read std::vector<int>") {
        auto vec = std::vector{1, 2, 3};
        CHECK(vec == write_then_read(vec));
}
TEST_CASE("write/read std::vector<double>") {
    auto vec = std::vector{1.0, 2.0, 3.0};
    CHECK(write_then_read(vec) == vec);
}
TEST_CASE("write/read std::vector<complex>") {
    using namespace std::complex_literals;
    auto vec = std::vector{1.0 + 1.0i, 2.0 + 2.0i, 2.0 + 2.0i};
    CHECK(write_then_read(vec) == vec);
}

