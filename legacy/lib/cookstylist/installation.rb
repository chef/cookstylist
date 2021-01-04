module Cookstylist
  class Installation
    attr_reader :id, :repos

    def initialize(id)
      @id = id

      # we need a fresh connection for each installation because the JWT can only be used for a single installation
      Cookstylist::Github.instance.reset_connection(@id)
      @gh_conn = Cookstylist::Github.instance.connection

      @repos = authorized_repos
    end

    #
    # Return all authorized repos with the language type of Ruby for the installation
    #
    # @return [Array]
    #
    def authorized_repos
      @gh_conn.list_installation_repos["repositories"].select { |x| x["language"] == "Ruby" }
    end
  end
end