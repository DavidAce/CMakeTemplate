
#include <Eigen/Eigenvalues>
#include <iostream>

// https://compiler-explorer.com/z/T1MrbrEjh
// https://eigen.tuxfamily.org/dox/classEigen_1_1EigenSolver.html
int main(){

    Eigen::MatrixXd H (10,10);             // Initialize a 10x10 square matrix
    H.setRandom();                         // Randomize (gaussian U(-1,1) )
    H = (H + H.transpose()).eval();        // Symmetrize (evaluate the temporary object before writing back into H)

    Eigen::EigenSolver<Eigen::MatrixXd> generalSolver(H); // Initialize a solver object taking H as a parameter
    Eigen::VectorXcd evals_cplx =  generalSolver.eigenvalues();
    std::cout << evals_cplx << std::endl;


    // Faster to use the Hermitian solver!
    Eigen::SelfAdjointEigenSolver<Eigen::MatrixXd> hermitianSolver(H);
    Eigen::VectorXd evals_real =  hermitianSolver.eigenvalues();
    std::cout << evals_real << std::endl;

}