//
// Created by david on 2019-03-27.
//

#ifndef LOGGER_H
#define LOGGER_H
#include <spdlog/spdlog.h>
#include <spdlog/sinks/stdout_color_sinks.h>

namespace Logger{
    inline void enableTimeStamp(std::shared_ptr<spdlog::logger> &log){
        if(log != nullptr) {
            log->set_pattern("[%Y-%m-%d %H:%M:%S][%n]%^[%=8l]%$ %v");
        }
    }
    inline void disableTimeStamp(std::shared_ptr<spdlog::logger> &log){
        if(log != nullptr){
            log->set_pattern("[%n]%^[%=8l]%$ %v");
        }
    }

    inline void setLogLevel(std::shared_ptr<spdlog::logger> &log, size_t levelZeroToSix){
        if (levelZeroToSix > 6) {
            throw std::runtime_error( "Expected verbosity level integer in [0-6]. Got: " + std::to_string(levelZeroToSix));
        }
        auto lvlEnum = static_cast<spdlog::level::level_enum>(levelZeroToSix);

        // Set console settings
        log->set_level(lvlEnum);
    }


    inline size_t getLogLevel(std::shared_ptr<spdlog::logger> &log){
        return static_cast<size_t>(log->level());
    }

    inline void setLogger(std::shared_ptr<spdlog::logger> &log, std::string name, size_t levelZeroToSix = 2, bool timestamp = true){
        if(spdlog::get(name) == nullptr){
            log = spdlog::stdout_color_mt(name);
            if (timestamp){enableTimeStamp(log);}
            else{disableTimeStamp(log); }
            setLogLevel(log,levelZeroToSix);
        }else{
            log = spdlog::get(name);
        }
    }

    inline std::shared_ptr<spdlog::logger>  setLogger(std::string name, size_t levelZeroToSix = 2, bool timestamp = true){
        if(spdlog::get(name) == nullptr){
            auto log = spdlog::stdout_color_mt(name);

            if (timestamp){enableTimeStamp(log);}
            else{disableTimeStamp(log); }
            setLogLevel(log,levelZeroToSix);
            return log;
        }else{
            return spdlog::get(name);
        }
    }


}

#endif //LOGGER_H
