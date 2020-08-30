require "octokit"
require "faraday-http-cache"

module Cookstylist
  class Github
    attr_reader :connection

    def initialize
      @connection = connection
    end

    def connection
      conn = Octokit::Client.new(bearer_token: jwt_token)
      conn.auto_paginate = true
      conn.middleware = Faraday::RackBuilder.new do |builder|
        builder.use Faraday::HttpCache
        builder.use Octokit::Response::RaiseError
        builder.adapter Faraday.default_adapter
      end

      conn
    end

    def jwt_token
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
  end
end