# Rack::Cors::CsrfPrevention

Ruby implementation of [CSRF prevention from the Apollo Router](https://www.apollographql.com/docs/router/configuration/csrf/).

## Installation

Install the gem and add to the application's Gemfile by executing:

```shell
bundle add rack-cors-csrf_prevention
```

If bundler is not being used to manage dependencies, install the gem by executing:

```shell
gem install rack-cors-csrf_prevention
```

## Configuration

### Rails Configuration

```ruby
# config/initializers/cors.rb

Rails.application.config.middleware.use Rack::Cors::CsrfPrevention
```

#### Paths

By default, the gem protects only `/graphql` path.

You can set your path using `path` argument:

```ruby
config.middleware.use Rack::Cors::CsrfPrevention, path: "/gql"
```

Also, you can configure multiple paths via `paths` argument.

#### Headers

By default, gem allows only `X-Apollo-Operation-Name` or `Apollo-Require-Preflight` header for non-preflighted content types.

You can add additional headers for CSRF prevention:

```ruby
config.middleware.use Rack::Cors::CsrfPrevention,
                      required_headers: %w[SOME-SPECIAL-HEADER]
```

#### Error message

By default, gem returns detailed error message that can help API clients in development.

You can hide detailed error message in a production environment:

```ruby
config.middleware.use Rack::Cors::CsrfPrevention, detailed_error: !Rails.env.production?
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`bin/rake spec` to run the tests. You can also run `bin/console` for an
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bin/rake install`.
To release a new version, update the version number in `version.rb`, and then
run `bin/rake release`, which will create a git tag for the version,
push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/digitaz/rack-cors-csrf_prevention.
