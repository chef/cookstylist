require "sinatra"
require 'resque'
require 'json'
require 'openssl'

module Cookstylist
  class Reactor < Sinatra::Base
    #before do
    #   @payload_body = request.body.read
    #   request_signature = request.env.fetch("HTTP_X_HUB_SIGNATURE", "")
    #   puts "The env is:" + ENV['GH_SECRET_TOKEN']
    #   require 'pry'; binding.pry
    #   check_signature = "sha1=" + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha1"), ENV['GH_SECRET_TOKEN'], @payload_body)
    #   return halt 500, "Signatures didn't match!" unless Rack::Utils.secure_compare(check_signature, request_signature)
    #end

    set :bind, ENV['BIND_IP'] || "0.0.0.0"
    set :port, ENV['BIND_PORT'] || 8080

    set(:event_type) do |type|
      condition { request.env["HTTP_X_GITHUB_EVENT"] == type }
    end

    post "/", event_type: "installation_repositories" do
      request_body = JSON.parse(request.body.read)

      if request_body['action'] == 'added'
        Resque.enqueue_to(:new_install, Cookstylist, request_body['installation']['id'])

        logger.info "Installation ID #{request_body['installation']['id']} has been queued for org #{request_body['installation']['login']}"
        [200, {}, "queued"]
      else
        logger.info "action #{request_body['action']} skipped"
        [200, {}, "action skipped"]
      end
    end
  end
end
