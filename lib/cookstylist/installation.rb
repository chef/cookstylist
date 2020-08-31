module Cookstylist
  class Installation
    attr_reader :id, :repos

    def initialize(id)
      @gh_conn = Cookstylist::Github.instance.connection
      @id = id
      @token = token
      @repos = repos
    end

    #
    # The GitHub token for this particular installation. You need to use a per installation token to get access to anything
    # the app was granted access to
    #
    # @return [String]
    #
    def token
      @gh_conn.create_app_installation_access_token(@id).token
    end

    #
    # Return all authorized repos with the language type of Ruby for the installation
    #
    # @return [Array]
    #
    def repos
      @gh_conn.access_token = @token
      @gh_conn.list_installation_repos["repositories"].select { |x| x["language"] == "Ruby" }
    end
  end
end