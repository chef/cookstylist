module Cookstylist
  class Corrector
    require "mixlib/shellout" unless defined?(Mixlib::ShellOut)
    require "json" unless defined?(JSON)
    require "cookstyle/version"

    attr_reader :results, :release

    def initialize(path)
      @path = path
      @results = nil
      @release = cookstyle_release
    end

    def cookstyle_release
      Cookstyle::VERSION.gsub(".", "_")
    end

    #
    # Run cookstyle on the path and set the @results variable
    #
    # @return [String] What is the repo's default branch
    #
    def run
      cmd = Mixlib::ShellOut.new("cookstyle --format json -a --except ChefCorrectness/MetadataMissingName #{@path}")
      cmd.run_command

      # rubocop will error out on old configs a lot so ignore the config if we fail
      # we can't call .error? because rubocop will throw a exit code of 1 if there's something that can still be autocorrected
      # which results in a lot of false positives
      unless cmd.stderr.nil? || cmd.stderr.empty?
        # @todo: We need to reset the repo at this point
        cmd = Mixlib::ShellOut.new("cookstyle --format json --force-default-config -a --except ChefCorrectness/MetadataMissingName #{@path}")
        cmd.run_command
      end

      @results = JSON.parse(cmd.stdout)
    end

    def summary
      @results["summary"]
    end

    #
    # RuboCop json output is by file, which isn't super handy when writing out summary reports
    # this method flips that output to be by cop, which is a bit easier to quickly scan through
    # and if there's a good number of RuboCop style violations it's easier to ignore those and
    # focus just on the ChefWhatever departments
    #
    # @return [Hash] Hash of cops names with arrays of offense hashes
    #
    def results_by_cop
      cop_results = {}

      @results["files"].each do |file|
        next if file["offenses"].empty? # we don't care about files w/o offenses

        file["offenses"].each do |offense|
          # create the array for this particular cop if it's not already there
          cop_results[offense["cop_name"]] = [] unless cop_results[offense["cop_name"]]

          # Add the file path to the offense since we're flipping the data structure
          # make sure we don't expose where we store the files though
          offense["file_path"] = file["path"].delete_prefix(@path)
          cop_results[offense["cop_name"]] << offense
        end
      end
      cop_results
    end
  end
end
