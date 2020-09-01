module Cookstylist
  require_relative "cookstylist/log"
  require_relative "cookstylist/github"
  require_relative "cookstylist/installation"
  require_relative "cookstylist/repo"
  require_relative "cookstylist/corrector"
  require_relative "cookstylist/pullrequest"

  def self::run
    installations = Cookstylist::Github.instance.installation_ids

    installations.each do |id|
      installation = Cookstylist::Installation.new(id)

      installation.repos.each do |repo_data|
        repo = Cookstylist::Repo.new(repo_data)
        puts "#{repo_data[:full_name]}:"
        puts "  looks_like_cookbook?: #{repo.looks_like_cookbook?}"
        puts "  fork?: #{repo.fork?}"
        next unless !repo.fork? && repo.looks_like_cookbook?

        puts "  Cloned to #{repo.clone}"

        print "  Running Cookstyle against the local repo: "
        corrector = Cookstylist::Corrector.new(repo.local_path)
        corrector.run
        puts "#{corrector.summary["offense_count"]} offenses!"

        next unless repo.dirty?

        puts "  Opening pull request to upstream"
        Cookstylist::Pullrequest.new(repo, corrector).open
      end
    end
  end
end