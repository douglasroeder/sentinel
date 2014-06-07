# Sentinel

Sentinel is a SalesForce integration gem. 

## Installing

Add this line to your application's Gemfile:

```ruby
gem 'sentinel', :git => 'git@bitbucket.org:mandrakez/sentinel.git'
```

Then `bundle install`.

## Usage

Here's a quick example, adding the Sentinel configuration to a Rails app in `config/initializers/sentinel.rb`:

```ruby
Sentinel.configure do |c|
  c.client_id = "CLIENT_ID"
  c.client_secret = "CLIENT_SECRET"
end
```

It depends on an OAuth2 integration, so you will need to pass the OAuth Token
and Secret to allow Sentinel do any entity action.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
