

void simple_function() {
    // Do something
}

int add_numbers_A(int a, int b) {
    return a + b;
}

int add_numbers_B(int a, int b) {
    return a + b;
}

int add_numbers_C(const int a, const int b) {
    return a + b;
}

int add_numbers_D(const int &a, const int &b) {
    return a + b;
}

auto add_numbers_E(const int &a, const double &b) {
    return a + b;
}

void add_numbers_F(const int &a, const int &b, int &result) {
    result = a + b;
}

[[nodiscard]] int add_numbers_G(const int &a, const int &b) noexcept {
    return a + b;
}

int main() {
    add_numbers_E(5, 3);
}