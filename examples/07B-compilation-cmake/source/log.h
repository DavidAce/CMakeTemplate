#pragma once
#include <spdlog/sinks/stdout_color_sinks.h>
#include <spdlog/spdlog.h>

namespace logger{
    inline std::shared_ptr<spdlog::logger> log;
}
