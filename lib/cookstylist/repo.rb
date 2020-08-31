module Cookstylist
  class Repo
    require "git"
    require "fileutils"

    attr_reader :name

    def initialize(metadata)
      @name = metadata[:full_name]
      @metadata = metadata
      @gh_conn = Cookstylist::Github.instance.connection
    end

    #
    # @return [String] What is the repo's default branch
    #
    def default_branch
      @metadata[:default_branch]
    end

    #
    # @return [Boolean] Is the repo a fork?
    #
    def fork?
      @metadata[:fork]
    end

    #
    # @return [Boolean] Does the repo have a metadata.rb file?
    #
    def looks_like_cookbook?
      @gh_conn.contents(@name).any? { |x| x["name"] == "metadata.rb" }
    end

    #
    # Clone the repo to a local temp dir
    #
    # @return [String] The path of the local checkout
    #
    def clone
      uri = "https://#{@gh_conn.access_token}@github.com/#{@name}"
      local_dir = @name.gsub(/[^0-9A-Z]/i, "_")
      full_tmp_path = File.join(Dir.tmpdir, local_dir)

      # delete any existing checked out repos
      FileUtils.rm_rf(full_tmp_path)

      Git.clone(uri, local_dir, { path: Dir.tmpdir })

      full_tmp_path
    end

    #
    # @return [Boolean] Does a branch named 'cookstyle' already exist?
    #
    def cookstyle_branch_exists?
      @gh_conn.branches(@name).any? { |x| x[:name] == "cookstyle" }
    end

    def checkout_cookstyle_branch

    end
  end
end