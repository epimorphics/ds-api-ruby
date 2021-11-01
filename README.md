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
to work.

## Tests

To run the tests you must set the environment variable `API_URL` to point to a
running instance of a valid SAPINT API and run:

```sh
rake test
```

If `API_URL` is not set it will default to `http://localhost:8888`
