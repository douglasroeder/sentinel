# Sentinel

Sentinel is a SalesForce integration gem. 

## Installing

Add this line to your application's Gemfile:

```ruby
gem 'sentinel', :git => 'git@github.com:mandrakez/sentinel.git'
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

This gem allows you to do simple data access operations, like
find/create/update.

### Sentinel::Model.find

```ruby
> contact = Contact.find('1')
> puts contact.email
=> "johndoe@gmail.com"
```

### Sentinel::Model.create

```ruby
> contact = Contact.new
> contact.name = "John Doe"
> contact.email = 'johndoe@example.org'
> contact.save
```

### Seninel::Model.update

```ruby
> contact = Contact.find('1')
> contact.email = 'johndoe@example.org'
> contact.save
```

## Extending

This is a generic gem, so you can improve and use other entities not provided
by the gem.

Example:

```ruby
class SfAccount
  include Sentinel::Model

  ## configure SalesForce entity
  set_sentinel_table 'Account'

  ## setup entity fields
  field :Name, alias: :name
  field :Email, alias: :email
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

