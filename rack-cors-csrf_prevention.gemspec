# frozen_string_literal: true

require_relative "lib/rack/cors/csrf_prevention/version"

Gem::Specification.new do |spec|
  spec.name = "rack-cors-csrf_prevention"
  spec.version = Rack::Cors::CsrfPrevention::VERSION
  spec.author = "Digital Classifieds LLC"
  spec.license = "MIT"

  spec.summary = "Ruby implementation of CSRF prevention from the Apollo Router."
  spec.description = <<~HEREDOC
    The middleware makes sure any request to specified paths would have been
    preflighted if it was sent by a browser.

    We don't want random websites to be able to execute actual GraphQL
    operations from a user's browser unless our CORS policy supports it. It's
    not good enough just to ensure that the browser can't read the response from
    the operation; we also want to prevent CSRF, where the attacker can cause
    side effects with an operation or can measure the timing of a read
    operation. Our goal is to ensure that we don't run the context function or
    execute the GraphQL operation until the browser has evaluated the CORS
    policy, which means we want all operations to be pre-flighted. We can do
    that by only processing operations that have at least one header set that
    appears to be manually set by the JS code rather than by the browser
    automatically.

    POST requests generally have a content-type `application/json`, which is
    sufficient to trigger preflighting. So we take extra care with requests that
    specify no content-type or that specify one of the three non-preflighted
    content types. For those operations, we require one of a set of specific
    headers to be set. By ensuring that every operation either has a custom
    content-type or sets one of these headers, we know we won't execute
    operations at the request of origins who our CORS policy will block.
  HEREDOC
  spec.homepage = "https://github.com/digitaz/rack-cors-csrf_prevention"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "rack", ">= 1"

  spec.add_development_dependency "debug", "~> 1.9", ">= 1.9.1"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.81", ">= 1.81.1"
end
