//
// Created by david on 2019-10-05.
//
#include "logger.h"

int main(){
    auto log = Logger::setLogger("test",0);

    log->info("This is a test!");

    return 0;
}
