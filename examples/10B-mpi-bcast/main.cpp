#include "cli.h"
#include "math/cast.h"
#include "rnd.h"
#include "settings.h"
#include <fmt/core.h>
#include <fmt/ranges.h>
#include <mpi.h>
#include <vector>
int main(int argc, char *argv[]) {
    cli::parse(argc, argv);

    // Initialize the MPI environment
    int world_rank = 0;
    int world_size = 0;

    MPI_Init(&argc, &argv);                     // Initialize. Parameters for mpi are parsed by mpi
    MPI_Comm_rank(MPI_COMM_WORLD, &world_rank); // Establish thread number of this worker
    MPI_Comm_size(MPI_COMM_WORLD, &world_size); // Get total number of threads

    rnd::seed(world_rank + settings::random::seed);

    // Initialize some data on all ranks, but populate it only on rank 0
    std::vector<double> data(100);

    if(world_rank == 0) {
        for(auto &elem : data) elem = rnd::uniform<double>(0, 1);
    }

    // Broadcast the data buffer from rank 0
    MPI_Bcast(data.data(), safe_cast<int>(data.size()), MPI_DOUBLE, 0, MPI_COMM_WORLD);

    double sum = 0;
    for(size_t idx = 0; idx < data.size(); ++idx) {
        sum += data[idx];
    }
    fmt::print("Hello world from process: {} / {}: sum = {:.6f}\n", world_rank, world_size, sum);

    MPI_Finalize();
}

/*
 * Questions:
 *
 *  - How do you send something with unkown size?
 *  - What happens if data.size() is larger than int?
 */
