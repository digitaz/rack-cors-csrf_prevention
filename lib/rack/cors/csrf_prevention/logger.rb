# frozen_string_literal: true

require "logger"

module Rack
  class Cors
    class CsrfPrevention
      module Logger
        def logger(env)
          @logger = if defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger
                      Rails.logger
                    elsif env[RACK_LOGGER]
                      env[RACK_LOGGER]
                    else
                      ::Logger.new($stdout).tap do |logger|
                        logger.level = ::Logger::Severity::DEBUG
                      end
                    end
        end
      end
    end
  end
end
