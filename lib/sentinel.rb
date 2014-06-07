require 'restforce'

require "sentinel/version"
require "sentinel/exceptions"
require "sentinel/model/model"

module Sentinel
  class << self
    # OAuth token authentication attribute
    attr_accessor :oauth_token

    # OAuth refresht_token authentication attribute
    attr_accessor :refresh_token

    # OmniAuth instance_url authentication attribute
    attr_accessor :instance_url

    # OAuth client_id application attribute
    attr_accessor :client_id

    # OAuth client_secret application attribute
    attr_accessor :client_secret

    def configure(&block)
      yield self
    end

    def valid_environment?
      valid = true

      [:oauth_token, :refresh_token, :instance_url, :client_id, :client_secret].each do |field|
        valid = false if send(field).to_s.empty?
      end

      return valid
    end

    def client
      raise Sentinel::InvalidEnvironmentError unless valid_environment?

      @client = Restforce.new oauth_token: oauth_token,
        refresh_token: refresh_token,
        instance_url: instance_url,
        client_id: client_id,
        client_secret: client_secret
    end
  end
end

