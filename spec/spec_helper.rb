require "simplecov"
SimpleCov.start

require "bundler/setup"
Bundler.require(:default, :development)

require "fakeweb"
require "sentinel"
require "sentinel/model/model"

FakeWeb.allow_net_connect = false

Dir["./spec/support/**/*.rb"].each {|file| require file }

RSpec.configure do |config|
  config.before(:each) do
    FakeWeb.clean_registry
  end
end
