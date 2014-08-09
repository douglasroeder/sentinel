# Sentinel
[![Build Status](https://travis-ci.org/mandrakez/sentinel.svg)](https://travis-ci.org/mandrakez/sentinel)
[![Code Climate](https://codeclimate.com/github/mandrakez/sentinel/badges/gpa.svg)](https://codeclimate.com/github/mandrakez/sentinel)

Sentinel is a SalesForce integration gem. This gem allows you to do simple data access operations, like **find/create/update**.

## Installing

Add this line to your application's Gemfile:

```ruby
gem 'sentinel', :git => 'git@github.com:mandrakez/sentinel.git'
```

Then `bundle install`.

## Usage

It depends on an OAuth2 integration, before you can execute any Sentinel operation, said that, we need to configure our OAuth credentials:

Example:

```ruby
Sentinel.configure do |c|
  c.oauth_token = session['oauth_token']
  c.instance_url = session['instance_url']
end
```

I suggest you to use **[omniauth-salesforce](https://github.com/realdoug/omniauth-salesforce)** to do that. I will not enter on details here, because you can find more information [here](https://github.com/realdoug/omniauth-salesforce).

## How it works

This is a generic gem, so you can improve and use other entities provided
by SalesForce.

Example:

```ruby
class Contact
  include ActiveModel::Model
  include ActiveModel::Validations
  include Sentinel::Model

  # SalesForce entity, will use class name if absent
  set_sentinel_table 'Contact'

  # Entity field names
  # 'alias' will generate getters/setters with specific name
  field :FirstName, alias: :first_name
  field :LastName, alias: :last_name
  field :Email, alias: :email
  field :Phone, alias: :telephone

  class << self
    def last_contacts
      query("SELECT Id, FirstName, LastName, Email, Phone FROM Contact ORDER BY CreatedDate DESC LIMIT 100")
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def persisted?
    !self.id.to_s.empty?
  end
end
```

### Searching

```ruby
> contact = Contact.find('1')
> puts contact.email
=> "johndoe@gmail.com"
```

or more complex filtering

```ruby
> contacts = Contact.query('SELECT Id, FirstName, LastName, Email, Phone FROM Contact LIMIT 10')
```

### Creating

```ruby
> contact = Contact.new
> contact.name = "John Doe"
> contact.email = 'johndoe@example.org'
> contact.save
=> true
```

or

```ruby
> contact = Contact.new(name: 'John', email: 'johndoe@gmail.com')
> contact.save
=> true
```

### Updating

```ruby
> contact = Contact.find('1')
> contact.email = 'johndoe@example.org'
> contact.save
=> true
```
or
```ruby
> contact = Contact.find('1')
> contact.update_attributes(email: 'johndoe@example.org')
=> true
```

### Destroying

```ruby
> Contact.destroy('1')
=> true
```

## TODO

There is still so much work to do:

* primary key probably should be a part of the model structure
* avoid primary key updates
* add new options to 'field' attributes:
 - read only flags
 - primary key
* understand better SalesForce exceptions
* increase test coverage

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

