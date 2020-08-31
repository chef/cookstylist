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
      require 'pry'; binding.pry
      cmd = Mixlib::ShellOut.new("cookstyle --format json -a #{@path}")
      cmd.run_command

    end
  end
end