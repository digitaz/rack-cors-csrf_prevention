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

Rails.application.config.middleware.use(
  Rack::Cors::CsrfPrevention,
  paths: %w[
    /graphql
    /admin/gql
  ],
  required_headers: %w[
    X-APOLLO-OPERATION-NAME
    APOLLO-REQUIRE-PREFLIGHT
    SOME-SPECIAL-HEADER
  ]
)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`bundle exec rake spec` to run the tests. You can also run `bin/console` for an
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then
run `bundle exec rake release`, which will create a git tag for the version,
push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/digitaz/rack-cors-csrf_prevention.
