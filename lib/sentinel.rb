require 'restforce'

require "sentinel/version"
require "sentinel/exceptions"
require "sentinel/model/model"

module Sentinel
  class << self
    # OAuth token authentication attribute
    attr_accessor :oauth_token

    # OmniAuth instance_url authentication attribute
    attr_accessor :instance_url

    def configure(&block)
      yield self
    end

    def valid_environment?
      valid = true

      [:oauth_token, :instance_url].each do |field|
        valid = false if send(field).to_s.empty?
      end

      return valid
    end

    def client
      raise Sentinel::InvalidEnvironmentError unless valid_environment?

      @client = Restforce.new oauth_token: oauth_token,
        instance_url: instance_url
    end
  end
end

