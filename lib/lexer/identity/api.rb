# encoding: utf-8
require 'multi_json'

# :nordoc:
module Lexer
  # :nordoc:
  module Identity
    # The backbone of the Identity API.
    # Enrich accepts links and attributes as per the
    # API Documentation hosted at http://developer.lexer.io/
    #
    # Options:
    #
    # +links+      - A hash of links to search for and link to the identity. Default: {}.
    # +attributes+ - A hash of attributes where keys are valid namespaces. Default: {}.
    #
    # Response:
    #
    # A hash containing the Lexer Identity ID and any attributes on the identity
    #
    def self.enrich(links: {}, attributes: {})
      # ensure the module is configured
      fail Lexer::Identity::ConfigurationError, 'Module has not been configured.' if configuration.nil?
      configuration.validate

      # produce the request body
      body = {}
      body[:links] = links
      body[:attributes] = attributes unless configuration.contributor_token.nil?
      body[:api_token] = configuration.api_token unless configuration.api_token.nil?
      body[:contributor_token] = configuration.contributor_token unless configuration.contributor_token.nil?
      body[:consumer_token] = configuration.consumer_token unless configuration.consumer_token.nil?

      post_request body
    end

    private

    def self.post_request(body)
      uri = URI(configuration.api_url)
      header = { 'Content-Type' => 'application/json' }
      request = Net::HTTP::Post.new(uri, header)
      request.body = MultiJson.encode(body)

      # XXX: SSL VALIDATION IS DISABLED - BAD BAD BAD
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
        http.request(request)
      end

      parse_response response
    end

    def self.parse_response(response)
      case response.code.to_i
      when 200..204
        Lexer::Identity::EnrichedResult.from_json response.body
      when 400
        fail Lexer::Identity::BadRequestError, response_body
      when 401
        fail Lexer::Identity::AuthenticationError, response_body
      when 404
        fail Lexer::Identity::NotFoundError, response_body
      else
        fail Lexer::Identity::HttpError, response_body
      end
    end
  end
end
