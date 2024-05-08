#include <fmt/core.h>
#include <mpi.h>

int main(int argc, char *argv[]) {
    // Initialize the MPI environment
    int world_rank = 0;
    int world_size = 0;

    MPI_Init(&argc, &argv);                     // Initialize. Parameters for mpi are parsed by mpi
    MPI_Comm_rank(MPI_COMM_WORLD, &world_rank); // Establish thread number of this worker
    MPI_Comm_size(MPI_COMM_WORLD, &world_size); // Get total number of threads

    for (int rank = 0; rank < world_size; ++rank) {
        if(world_rank == rank) {
            fmt::print("Hello world from process: {} / {}\n", world_rank, world_size);
        }
        MPI_Barrier(MPI_COMM_WORLD);
    }

    // MPI_Finalize();
}