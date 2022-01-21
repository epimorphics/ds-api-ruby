# Epimorphics Data Services API gem

This gem provides a Ruby API for back-end data services used in the HMLR
linked data applications. Specifically, it allows a simple expression language
to be used to specify queries into an [RDF data cube](https://www.w3.org/TR/vocab-data-cube/),
in which a collection of data readings, known as _measures_ are organised into a
hyper-cube of two or more _dimensions_.

## History

Originally, the expression language used by this gem was interpreted directly by
the [DsAPI](https://github.com/epimorphics/data-API/wiki). DsAPI presented a RESTful
API in which data expressions could be translated systematically into SPARQL
expressions, executed against a remote SPARQL endpoint, and then results
returned to the caller in a compact JSON format.

In 2021, we took the decision to retire the DsAPI codebase, which has not been
actively maintained for some time. In its place, we now expect to use
[SapiNT](https://github.com/epimorphics/sapi-nt). SapiNT performs a similar
function, in that it provides a RESTful API in which compact queries are translated
into SPARQL expressions, and the results are available in (amongst other formats)
JSON encoding. However, the input to SapiNT, in which we articulate the projection
of the underlying hypercube that we require is encoded as URL parameters in an
HTTP GET request. DsAPI, in contrast, expects the input query to be POSTed as a
JSON expression.

To minimise changes to the client applications in which this gem is used, we have
implemented a shim layer that accepts DsAPI expressions and re-codes them as SapiNT
URLs. Similarly, differences in the returned JSON results formats are also ironed
out by this shim layer. It is possible to do this because, once the designs of the
applications had settled, the HMLR apps only use a subset of the expressive power
of the DsAPI expression language.

It would be possible to simplify this code further, at the expense of needing to
make changes to the calling application code. At the time, we did not believe this
to be a cost-effective change, and no benefit to end-users (the internals of the
query language are not exposed to end-users). This calculation may be different in
future.


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
running instance of a valid SAPINT API and run `rake test`:

```sh
API_URL=http://localhost:8080 rake test
```

If `API_URL` is not set it will default to `http://localhost:8888`
