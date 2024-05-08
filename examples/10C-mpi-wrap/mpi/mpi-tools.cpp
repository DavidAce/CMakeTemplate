
#include "mpi-tools.h"
#include "../general/iter.h"
#include "../log.h"
#include "../math/num.h"
#include <mpi.h>

void mpi::init() {
    // Initialize the MPI environment
    MPI_Init(nullptr, nullptr);
    MPI_Comm_rank(MPI_COMM_WORLD, &world.id);   // Establish thread number of this worker
    MPI_Comm_size(MPI_COMM_WORLD, &world.size); // Get total number of threads

    if(world.id == 0) logger::log->info("MPI initialized with {} processes", world.size);
    if(world.size > 1) {
        mpi::on = true;
        auto logname = logger::log->name();
        auto width   = fmt::format("{}", world.size - 1).size();
        auto mpiname = fmt::format("{}-{:>{}}", logger::log->name(), world.id, width);
        auto level   = logger::log->level();
        logger::log  = spdlog::stdout_color_mt(mpiname, spdlog::color_mode::always);
        logger::log->set_level(level);
    }
}

void mpi::finalize() {
    if(world.size > 1 or mpi::on) MPI_Finalize();
}

void mpi::barrier() {
    if(world.size > 1 or mpi::on) MPI_Barrier(MPI_COMM_WORLD);
}

