#include "cli.h"
#include "math/cast.h"
#include "mpi/mpi-tools.h"
#include "log.h"
#include "rnd.h"
#include "settings.h"
#include <fmt/core.h>
#include <fmt/ranges.h>
#include <mpi.h>
#include <vector>

int main(int argc, char *argv[]) {
    cli::parse(argc, argv);

    mpi::init();                                       // Initialize MPI
    rnd::seed(mpi::world.id + settings::random::seed); // Seeds unique to each thread

    std::vector<double> data(20); // Initialize some data on all threads,
    if(mpi::world.id == 0) {       // but populate it only on rank 0
        for(size_t i = 0; i < data.size(); ++i) data[i] = i;
    }

    mpi::scatter(data, 0); // Scatter the data buffer from rank 0

    logger::log->info("data: {::.3f}", data);
    mpi::finalize(); // Initialize MPI
}

