require "octokit"
require "faraday-http-cache"
require "singleton"

module Cookstylist
  class Github
    include Singleton

    attr_reader :connection

    def initialize
      @connection = gh_connection
      @options = {accept: Octokit::Preview::PREVIEW_TYPES[:integrations]}
     # set_default_token
    end

    def gh_connection
      conn = Octokit::Client.new(bearer_token: json_web_token)
      conn.auto_paginate = true
      conn.middleware = Faraday::RackBuilder.new do |builder|
        builder.use Faraday::HttpCache
        builder.use Octokit::Response::RaiseError
        builder.adapter Faraday.default_adapter
      end

      conn
    end

    #
    # Generate a JSON Web Token from the app private key located at cookstyle.pem
    #
    # @return [String] JSON Web Token
    #
    def json_web_token
      require "openssl"
      require "jwt"

      private_key = OpenSSL::PKey::RSA.new(File.read("cookstyle.pem"))

      # Generate the JWT
      payload = {
        # issued at time
        iat: Time.now.to_i,
        # JWT expiration time (10 minute maximum)
        exp: Time.now.to_i + (10 * 60),
        # GitHub App's identifier
        iss: 78849,
      }

      token = JWT.encode(payload, private_key, "RS256")
      Cookstylist::Log.info("JWT token generated: #{token}")
      token
    end

    # use the token for the first app installation
    # as we grab data set the install token each time, but this gives us a working
    # connection object
    #
    # @return [void]
    #
    def set_default_token
      install_ids = @connection.find_app_installations(@options).collect { |x| x["id"] }

      token = install_ids.collect { |x| @connection.create_app_installation_access_token(x, @options).token }.first

      @connection.access_token = token
    end

    #
    # @return [Array] installation IDs of orgs with the app installed
    #
    def installation_ids
      @connection.find_app_installations(@options).collect { |x| x["id"] }
    end
  end
end