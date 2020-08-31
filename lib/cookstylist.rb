module Cookstylist
  require_relative "cookstylist/log"
  require_relative "cookstylist/github"
  require_relative "cookstylist/installation"
  require_relative "cookstylist/repo"

  def self::run
    installations = Cookstylist::Github.instance.installation_ids

    installations.each do |id|
      installation = Cookstylist::Installation.new(id)

      installation.repos.each do |repo_data|
        repo = Cookstylist::Repo.new(repo_data)
        puts "#{repo_data[:full_name]}:"
        puts "  looks_like_cookbook?: #{repo.looks_like_cookbook?}"
        puts "  fork?: #{repo.fork?}"
        puts "  Cloned to #{repo.clone}"
      end
    end
  end
end