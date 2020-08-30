module Cookstylist
  require_relative "cookstylist/log"
  require_relative "cookstylist/github"
  require_relative "cookstylist/repos"

  def self::run
    require "pry"; binding.pry
  end
end