module Cookstylist
  class Repo
    attr_reader :name

    def initialize(metadata)
      @name = metadata[:full_name]
      @metadata = metadata
      @gh_conn = Cookstylist::Github.instance.connection
    end

    def default_branch
      @metadata[:default_branch]
    end

    def fork?
      @metadata[:fork]
    end

    def looks_like_cookbook?
      @gh_conn.contents(@name).any? { |x| x["name"] == "metadata.rb" }
    end

    def clone

    end

    def cookstyle_branch_exists?
      @gh_conn.branches(@name).any? { |x| x[:name] == "cookstyle" }
    end

    def checkout_cookstyle_branch

    end
  end
end