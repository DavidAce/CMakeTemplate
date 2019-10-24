//
// Created by david on 2019-03-27.
//

#pragma once
#include <spdlog/logger.h>
#include <spdlog/fmt/bundled/ranges.h>
namespace Logger{
    extern void enableTimeStamp(std::shared_ptr<spdlog::logger> &log);
    extern void disableTimeStamp(std::shared_ptr<spdlog::logger> &log);
    extern void setLogLevel(std::shared_ptr<spdlog::logger> &log, size_t levelZeroToSix);
    extern size_t getLogLevel(std::shared_ptr<spdlog::logger> &log);
    extern void setLogger(std::shared_ptr<spdlog::logger> &log, std::string name, size_t levelZeroToSix = 2, bool timestamp = true);
    extern std::shared_ptr<spdlog::logger>  setLogger(std::string name, size_t levelZeroToSix = 2, bool timestamp = true);

}

