# Epimorphics Data Services API gem

This gem provides a Ruby API for the [data services API](https://github.com/epimorphics/data-API/wiki)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'data-api'
```

And then execute:

```sh
bundle
```

Also, an API URL needs to be provided for the Service class in order for the gem
to work

## Tests

To run the tests, use:

```sh
rake test
```

Also, a local SAPINT API must be running on port `8888` for these to work
