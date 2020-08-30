module Cookstylist
  require_relative "cookstylist/log"
  require_relative "cookstylist/github"

  def self::run
    require "pry"; binding.pry
  end
end