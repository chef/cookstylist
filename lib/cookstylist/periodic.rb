require "mixlib/cli" unless defined?(Mixlib::CLI)
require "resque"

module Cookstylist
  class Periodic
    include Mixlib::CLI
    banner(<<~RUBY)
     Cookstylist-periodic: Periodically enqueue Cookstyle app installations to scan

     Usage: cookstylist [options]
    RUBY

    option :log_level,
          short: "-l LOG_LEVEL",
          long: "--log-level LOG_LEVEL",
          description: "Set the logging level",
          proc: lambda { |l| l.to_sym }

    option :help,
           on: :tail,
           short: "-h",
           long: "--help",
           description: "Show this message",
           boolean: true,
           show_options: true,
           exit: 0

    def run(argv = ARGV)
      parse_options(argv)
      Config.merge!(config)
      Log.level = Config[:log_level]

      Log.info "Starting Cookstylist..."

      Cookstylist::Github.instance.installation_ids.each do |install|
        Resque.enqueue_to(:periodic, Cookstylist, install)
        Log.info "Queued Cookstyle installation: #{install}"
      end
    end
  end
end
