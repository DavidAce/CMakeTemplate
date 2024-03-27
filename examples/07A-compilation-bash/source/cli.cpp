#include "cli.h"
#include "rnd.h"
#include "log.h"
#include "settings.h"
#include <CLI/CLI.hpp>
#include <fmt/core.h>
int cli::parse(int argc, char *argv[]) {
    CLI::App app;
    app.description("CMT: example 06A - simulation");
    app.get_formatter()->column_width(90);
    app.option_defaults()->always_capture_default();
    app.allow_extras(false);

    // Transformer from string to enum for the random distribution
    auto dist_string2enum = std::array<std::pair<std::string, RandDist>, 2> {{{"UNIFORM", RandDist::UNIFORM}, {"NORMAL", RandDist::NORMAL}}};

    /* clang-format off */
    app.add_option("-s,--seed"          , settings::random::seed         , "Path to a .cfg or .h5 file from a previous simulation");
    app.add_option("-d,--dist"          , settings::random::distribution , "Select the random number distribution")->transform(CLI::CheckedTransformer(dist_string2enum, CLI::ignore_case));
    app.add_option("-o,--outfile"       , settings::io::outfile          , "Path to the output file");
    app.add_option("-l,--loglevel"      , settings::log::level           , "Verbosity 0:high --> 6:off")->check(CLI::Range(0,6));

    /* clang-format on */
    CLI11_PARSE(app,argc,argv);

    // Init
    rnd::seed(settings::random::seed);
    logger::log = spdlog::stdout_color_mt("CMT", spdlog::color_mode::always);
    logger::log->set_level(static_cast<spdlog::level::level_enum>(settings::log::level));
    return 0;
}