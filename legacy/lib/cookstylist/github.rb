require "octokit"
require "faraday-http-cache"
require "singleton" unless defined?(Singleton)

module Cookstylist
  class Github
    include Singleton

    attr_reader :connection

    def initialize
      @connection = gh_connection
      @options = { accept: Octokit::Preview::PREVIEW_TYPES[:integrations] }
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
    # Create a fresh connection using a new JWT since they can only be used once per installation
    # and then set the installation token from app ID
    #
    # @return [void]
    #
    def reset_connection(install_id)
      @connection = gh_connection
      @connection.access_token = @connection.create_app_installation_access_token(install_id).token
    end

    #
    # Generate a JSON Web Token from the app private key located at cookstyle.pem
    #
    # @return [String] JSON Web Token
    #
    def json_web_token
      require "openssl" unless defined?(OpenSSL)
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
      Log.debug("JWT token generated: #{token}")
      token
    end

    #
    # @return [Array] installation IDs of orgs with the app installed
    #
    def installation_ids
      @connection.find_app_installations(@options).collect { |x| x["id"] }
    end
  end
end