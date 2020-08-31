module Cookstylist
  class Repo
    require "git"
    require 'fileutils'

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
      uri = "https://#{@gh_conn.access_token}@github.com/#{@name}"
      local_dir = @name.gsub(/[^0-9A-Z]/i, '_')
      full_tmp_path = File.join(Dir.tmpdir, local_dir)

      # delete any existing checked out repos
      FileUtils.rm_rf(full_tmp_path)

      Git.clone(uri, local_dir, {path: Dir.tmpdir})

      full_tmp_path
    end

    def cookstyle_branch_exists?
      @gh_conn.branches(@name).any? { |x| x[:name] == "cookstyle" }
    end

    def checkout_cookstyle_branch

    end
  end
end