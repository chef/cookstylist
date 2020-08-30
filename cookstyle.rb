#!/usr/bin/env ruby

def jwt_token
  require 'openssl'
  require 'jwt'

  private_key = OpenSSL::PKey::RSA.new(File.read("cookstyle.pem"))

  # Generate the JWT
  payload = {
    # issued at time
    iat: Time.now.to_i,
    # JWT expiration time (10 minute maximum)
    exp: Time.now.to_i + (10 * 60),
    # GitHub App's identifier
    iss: 78849
  }

  JWT.encode(payload, private_key, "RS256")
end

def gh_connection
  require 'octokit'
  require 'faraday-http-cache'

  @connection ||= begin
    connection = Octokit::Client.new(bearer_token: jwt_token)
    connection.auto_paginate = true
    connection.middleware = Faraday::RackBuilder.new do |builder|
      builder.use Faraday::HttpCache
      builder.use Octokit::Response::RaiseError
      builder.adapter Faraday.default_adapter
    end
    connection
  end
end

install_ids = gh_connection.find_app_installations.collect {|x| x['id'] }

tokens = install_ids.collect {|x| gh_connection.create_app_installation_access_token(x).token }

tokens.each do |t|
  gh_connection.access_token = t
  @ruby_repos = gh_connection.list_installation_repos['repositories'].select{|x| x['language'] == 'Ruby'}
end

@ruby_repos.each do |repo|
  #sha = gh_connection.ref(repo['full_name'],"heads/#{repo['default_branch']}").object.sha
  #gh_connection.create_ref(repo['full_name'], "heads/cookstyle_bot", sha)

  require 'git'
end
