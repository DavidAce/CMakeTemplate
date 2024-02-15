#include <Eigen/Core>
#include <h5pp/h5pp.h>



int main() {
    // Initialize data
    std::vector<std::complex<double>> hamiltonian_vector(100);                               // Let a vector own the data
    Eigen::Map<Eigen::MatrixXcd>      hamiltonian_matrix(hamiltonian_vector.data(), 10, 10); // View the hamiltonian data as a 10x10 matrix

    // Initialize file
    h5pp::File file("example04B.h5", h5pp::FileAccess::REPLACE);

    // Write data
    file.writeDataset(hamiltonian_matrix, "projectB/experiment2/mymatrix");

    // Read data
    auto readAsVector = file.readDataset<std::vector<std::complex<double>>>("projectB/experiment2/mymatrix");
    auto readAsMatrix = file.readDataset<Eigen::MatrixXcd>("projectB/experiment2/mymatrix");
}
