# frozen_string_literal: true

require "rack"
require_relative "csrf_prevention/logger"
require_relative "csrf_prevention/version"

module Rack
  class Cors
    class CsrfPrevention
      include Rack::Cors::CsrfPrevention::Logger

      APOLLO_CUSTOM_PREFLIGHT_HEADERS = %w[
        X-APOLLO-OPERATION-NAME
        APOLLO-REQUIRE-PREFLIGHT
      ].freeze

      NON_PREFLIGHTED_CONTENT_TYPES = %w[
        application/x-www-form-urlencoded
        multipart/form-data
        text/plain
      ].freeze

      ERROR_MESSAGE = <<~HEREDOC
        This operation has been blocked as a potential Cross-Site Request Forgery (CSRF).

        Please either specify a "Content-Type" header (with a mime-type that is not one of #{NON_PREFLIGHTED_CONTENT_TYPES.join(', ')}) or provide one of the following headers: #{APOLLO_CUSTOM_PREFLIGHT_HEADERS.join(', ')}.
      HEREDOC

      def initialize(
        app,
        paths:,
        required_headers: APOLLO_CUSTOM_PREFLIGHT_HEADERS
      )
        @app = app
        @paths = paths
        @required_headers = required_headers
      end

      def call(env)
        request = ::Rack::Request.new(env)

        return @app.call(env) unless protected_path?(request.path)

        if preflighted?(request)
          logger(env).debug { "Request is preflighted" }

          @app.call(env)
        else
          logger(env).debug { "Request isn't preflighted" }

          Rack::Response[400, { "Content-Type" => "text/plain" }, ERROR_MESSAGE].to_a
        end
      end

      private

      def protected_path?(path)
        @paths.include?(path)
      end

      def preflighted?(request)
        content_type_requires_preflight?(request) || recommended_header_provided?(request)
      end

      def content_type_requires_preflight?(request)
        !NON_PREFLIGHTED_CONTENT_TYPES.include?(request.media_type)
      end

      def recommended_header_provided?(request)
        @required_headers.any? { |header| request.has_header?("HTTP_#{header}") }
      end
    end
  end
end
