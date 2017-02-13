# encoding: utf-8
require 'logger'

module Lexer
  # Identity allows businesses to Contribute or Consume data from
  # the Lexer Identity platform.
  #
  # The module acts as a light wrapper to the Identity API who's
  # documentation can be found at http://lexer.io.
  #
  # See +Lexer::Identity.configuration+ and
  # +Lexer::Identity.enrich+ for more details.
  #
  # To use the API you will first require API tokens which should have
  # been provided to you already, or can be obtained from support@lexer.io.
  #
  # Basic use of the gem is as follows:
  #
  #   Lexer::Identity.configure do |config|
  #     config.api_token = "..."
  #     config.contributor_token = "..."
  #     config.consumer_token = "..."
  #   end
  #
  #   Lexer::Identity.enrich(id: "...", links: {email: "...", ...}, attributes: {"com.mybrand.name": "...", ...})
  #
  # See the +Lexer::Identity.enrich+ documentation for more details.
  module Identity
    # Base RuntimeError class for Identity related errors.
    # Most Lexer and Identiy errors inherit this class.
    class Error < RuntimeError
      attr_accessor :original_error
      def initialize(message, original = nil)
        self.original_error = original
        Lexer::Identity.logger.error("#{self}: #{message}")
        super(message)
      end

      def to_s
        "Lexer Identity Exception: #{super}"
      end
    end

    # Will be thrown when there is an error with the Module's configuration
    class ConfigurationError < Error; end

    # Thrown when the attribute payload is not valid
    class AttributePayloadError < Error; end

    # Thrown when a request does not contain an ID or Link
    class MissingLinksError < Error; end

    # Will be thrown when there is an error communicating with the API
    # Also inherited by other errors
    class HttpError < Error; end

    # Will be thrown when there is an error in the API request
    class BadRequestError < HttpError; end

    # Will be thrown when the tokens are invalid
    class AuthenticationError < HttpError; end

    # Will be thrown when the object can't be loaded from the API
    class NotFoundError < HttpError; end

    # Will be thrown when too many updates are attempted on an identity in a
    # short space of time (3 min)
    class TooManyRequests < HttpError; end

    # inherit configuration
    class << self
      attr_accessor :configuration
      attr_writer :logger

      # Defines the modules logger
      # Accessible via:
      #
      #    Lexer::Identity.logger
      #
      def logger
        @logger ||= lambda do
          logger = Logger.new($stdout)
          logger.level = Logger::INFO
          logger
        end.call
      end
    end

    # Creates or uses active configutation
    # See +Lexer::Identity.configuration+ for options
    def self.configure
      self.configuration ||= Configuration.new
      yield(configuration)

      self.configuration
    end
  end
end

require 'lexer/identity/configuration'
require 'lexer/identity/api'
require 'lexer/identity/enriched_result'
