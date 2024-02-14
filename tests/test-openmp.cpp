#include <iostream>
#include <thread>

#ifdef _OPENMP
#include <omp.h>
#endif



int main(){
    auto std_threads = std::thread::hardware_concurrency();
    auto omp_threads = omp_get_max_threads();
    std::cout << "Machine has " << std_threads << " threads available" << std::endl;
    std::cout << "Using OpenMP with max " << omp_threads << " threads" << std::endl;

    omp_set_num_threads(4);
    int counter = 0;
    #pragma omp parallel for shared(counter)
    for(int i = 0; i < 16; i++){
        #pragma omp atomic
        counter++;
    }
    std::cout << "Counter is: " << counter << std::endl;

    return 0;
}
