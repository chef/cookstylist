require "mixlib/cli" unless defined?(Mixlib::CLI)

module Cookstylist
  class CLI
    include Mixlib::CLI

    banner(<<~RUBY)
     Cookstylist: The binary behind the GitHub Cookstyle App

     Usage: cookstylist [options]
    RUBY

    option :log_level,
          short: "-l LOG_LEVEL",
          long: "--log-level LOG_LEVEL",
          description: "Set the logging level",
          proc: lambda { |l| l.to_sym }

    option :whyrun,
           short: "-w",
           long: "--[no-]whyrun",
           description: "Do not push branches or create pull requests on GitHub",
           boolean: false

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

      installations = Cookstylist::Github.instance.installation_ids

      installations.each do |id|
        installation = Cookstylist::Installation.new(id)

        installation.repos.each do |repo_data|
          repo = Cookstylist::Repo.new(repo_data)
          Log.info "#{repo_data[:full_name]}:"
          Log.info "  looks_like_cookbook?: #{repo.looks_like_cookbook?}"
          Log.info "  fork?: #{repo.fork?}"
          next unless !repo.fork? && repo.looks_like_cookbook?

          Log.info "  Cloned to #{repo.clone}"

          Log.info "  Running Cookstyle against the local repo: "

          # if there's already a branch pushed up for this release of cookstyle then
          # we've already run for this version and we can skip to the next repo
          next if repo.cookstyle_branch_exists?

          repo.checkout_cookstyle_branch
          corrector = Cookstylist::Corrector.new(repo.local_path)
          corrector.run
          Log.info "  #{corrector.summary["offense_count"]} offenses detected!"

          next unless repo.dirty?

          Log.info "  Opening pull request to upstream"
          Cookstylist::Pullrequest.new(repo, corrector).open
        end
      end
    end
  end
end
