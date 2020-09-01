module Cookstylist
  class Pullrequest
    require "git"

    def initialize(repo, corrector)
      @repo = repo
      @corrector = corrector
      @gh_conn = Cookstylist::Github.instance.connection
      require 'pry'; binding.pry
    end

  
  end
end