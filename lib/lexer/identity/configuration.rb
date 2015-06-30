# encoding: utf-8

# :nordoc:
module Lexer
  # :nordoc:
  module Identity
    # Stores configuration details for communicating with the Lexer Identiy API.
    class Configuration
      # The full path to the API and endpoint
      attr_accessor :api_url

      # the API token provided by Lexer
      attr_accessor :api_token

      # the contributor token provided by Lexer
      attr_accessor :contributor_token

      # the consumer token provided by Lexer
      attr_accessor :consumer_token

      # Creates the configuration instance and defines default values
      def initialize
        @api_url = 'https://identity.api.lexer.io/'
        @api_token = nil
        @contributor_token = nil
        @consumer_token = nil
      end

      # validates the current configuration, raising exceptions when invalid
      def validate
        fail Lexer::Identity::ConfigurationError, 'An API token is required' if @api_token.nil?
        fail Lexer::Identity::ConfigurationError, 'A Contributor or Consumer token is required' if @contributor_token.nil? && @consumer_token.nil?
        fail Lexer::Identity::ConfigurationError, 'Contributor and Consumer tokens are not interchangable' if @contributor_token == @consumer_token
      end
    end
  end
end
