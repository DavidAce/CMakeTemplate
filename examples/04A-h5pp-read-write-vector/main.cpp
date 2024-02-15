#include <h5pp/h5pp.h>

int main() {
    // Initialize data
    std::vector<double> data = {1.0, 2.0, 3.0, 4.0, 5.0};

    // Initialize file
    h5pp::File file("example04A.h5", h5pp::FileAccess::REPLACE);

    // Write data
    file.writeDataset(data, "projectA/experiment1/mydata");

}



// How do we enable compression?
// How do we read data?
// What if we are not sure if the dataset exists in the file?


