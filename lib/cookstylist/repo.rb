module Cookstylist
  class Repo
    require "git"
    require "fileutils"

    attr_reader :name, :local_path, :git_repo

    def initialize(metadata)
      @name = metadata[:full_name]
      @metadata = metadata
      @local_path = ::File.join(Dir.tmpdir, @name.gsub(/[^0-9A-Z]/i, "_"))
      @git_repo = nil
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
      uri = "https://cookstyle:#{@gh_conn.access_token}@github.com/#{@name}"
      local_dir = @name.gsub(/[^0-9A-Z]/i, "_")

      # delete any existing checked out repos
      FileUtils.rm_rf(@local_path)

      @git_repo = Git.clone(uri, local_dir, { path: Dir.tmpdir })

      @local_path
    end

    #
    # @return [String] The cookstyle versioned branch name
    #
    def cookstyle_branch_name
      @branch_name ||= begin
        require 'cookstyle'
        "cookstyle_bot/cookstyle_" + Cookstyle::VERSION.gsub(".", "_")
      end
    end

    #
    # @return [Boolean] Does a branch named 'cookstyle_bot/cookstyle_X_Y_Z' already exist?
    #
    def cookstyle_branch_exists?
      !!@git_repo.branches[cookstyle_branch_name]
    end

    #
    # Checkout (and create if necessary) the cookstyle branc
    #
    # @return [void]
    #
    def checkout_cookstyle_branch
      @git_repo.branch(cookstyle_branch_name).checkout
    end

    #
    # @return [Boolean] Are there uncommitted changes in the repo
    #
    def dirty?
      !@git_repo.status.changed.empty?
    end
  end
end