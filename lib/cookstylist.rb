require "mixlib/log"
require "mixlib/config" unless defined?(Mixlib::Config)

require_relative "cookstylist/cli"
require_relative "cookstylist/github"
require_relative "cookstylist/installation"
require_relative "cookstylist/repo"
require_relative "cookstylist/corrector"
require_relative "cookstylist/pullrequest"

module Cookstylist
  class Log
    extend Mixlib::Log
  end

  module Config
    extend Mixlib::Config

    default :log_level, :info
  end
end
