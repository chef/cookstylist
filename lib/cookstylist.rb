module Cookstylist
  require_relative "cookstylist/log"
  require_relative "cookstylist/github"
  require_relative "cookstylist/installation"
  require_relative "cookstylist/repo"

  def self::run
    installations = Cookstylist::Github.instance.installation_ids

    installations.each do |id|
      install = Cookstylist::Installation.new(id)
      install.repos
    end
  end
end