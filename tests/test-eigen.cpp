#include <Eigen/Core>
#include <iostream>
int main(){
    Eigen::MatrixXd test(10,10);
    test.setRandom();
    std::cout << test << std::endl;
    return 0;
}
