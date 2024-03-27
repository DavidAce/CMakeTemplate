#include <chrono>
#include <fmt/core.h>
class tictoc {
    using hresclock  = std::chrono::high_resolution_clock;
    using duration_t = std::chrono::duration<double>;

    private:
    hresclock::time_point tstart;
    std::string           tname;

    public:
    tictoc(const std::string &name = "") {
        tstart = hresclock::now();
        tname  = name;
    }
    ~tictoc() {
        double result = std::chrono::duration_cast<duration_t>(hresclock::now() - tstart).count();
        fmt::print("lifetime [{}]: {:.8f} s\n", tname, result);
    }
};

void func() {
    auto t = tictoc("func");

}


int main() {
    auto t = tictoc("main");
    func();
}