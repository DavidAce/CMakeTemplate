#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN

#include <h5pp/h5pp.h>
#include <doctest/doctest.h>


std::vector<int> write_and_read(const std::vector<int> &vec) {
    auto f = h5pp::File("test-h5pp.h5", h5pp::FileAccess::REPLACE);
    f.writeDataset(vec, "vec");
    return f.readDataset<std::vector<int>>("vec");
}

TEST_CASE("std::vector<int>") {
    auto vec = std::vector<int>{1, 2, 3};
    CHECK(write_and_read(vec) == vec);
}
