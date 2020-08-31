module Cookstylist
  class Corrector
    require "mixlib/shellout"
    require "json"

    attr_reader :results

    def initialize(path)
      @path = path
      @results = nil
    end

    #
    # Run cookstyle on the path and set the @results variable
    #
    # @return [String] What is the repo's default branch
    #
    def run
      cmd = Mixlib::ShellOut.new("cookstyle --format json -a #{@path}")
      cmd.run_command

      # rubocop will error out on old configs a lot so ignore the config if we fail
      if cmd.error?
        cmd = Mixlib::ShellOut.new("cookstyle --format json --force-default-config -a #{@path}")
        cmd.run_command
      end

      @results = JSON.parse(cmd.stdout)
    end

    def summary
      @results["summary"]
    end
    end
  end
end