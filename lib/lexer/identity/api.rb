# encoding: utf-8
require 'multi_json'

# :nordoc:
module Lexer
  # :nordoc:
  module Identity
    # Constants for attribute confidence
    CONFIDENCE_PROVIDED   = 2
    CONFIDENCE_CALCULATED = 1
    CONFIDENCE_INFERRED   = 0

    # The backbone of the Identity API.
    # Enrich accepts links and attributes as per the
    # API Documentation hosted at http://developer.lexer.io/
    #
    # Options:
    #
    # +id+         - A string of the Lexer Identity ID to lookup
    # +links+      - A hash of links to search for and link to the identity. Default: {}.
    # +attributes+ - A hash of attributes where keys are valid namespaces. Default: {}.
    #
    # An +id+ or +links+ is required for a valid request.
    #
    # Response:
    #
    # A hash containing the Lexer Identity ID and any attributes on the identity
    #
    def self.enrich(id: nil, links: {}, attributes: {}, unify: false)
      body = {}

      # ensure the module is configured
      fail Lexer::Identity::ConfigurationError, 'Module has not been configured.' if configuration.nil?
      configuration.validate

      # use the id if provided
      if id.nil?
        if links.keys.size == 0
          fail Lexer::Identity::MissingLinksError, 'An ID or Link is required'
        else
          body[:links] = links
        end
      else
        body[:id] = id
      end

      # only include attributes if contributing
      if !configuration.contributor_token.nil? && (attributes.keys.size > 0)
        validate_attributes(attributes)
        body[:attributes] = attributes
      end

      # Unify the identity if given a contributor token and the request body
      # contains unify: true
      body[:unify] =
        if !configuration.contributor_token.nil?
          unify
        else
          false
        end

      body[:api_token] = configuration.api_token unless configuration.api_token.nil?
      body[:contributor_token] = configuration.contributor_token unless configuration.contributor_token.nil?
      body[:consumer_token] = configuration.consumer_token unless configuration.consumer_token.nil?

      post_request(body)
    end

    private

    def self.validate_attributes(attributes)
      attributes.each do |k, v|
        unless v.is_a?(Hash)
          fail Lexer::Identity::AttributePayloadError, "#{k} is not a hash"
        end

        unless [:value, :confidence].all? { |required_key| v.key?(required_key) || v.key?(required_key.to_s) }
          fail Lexer::Identity::AttributePayloadError, "#{k} has an invalid payload"
        end
      end
    end

    def self.post_request(body)
      uri = URI(configuration.api_url)
      header = {'Content-Type' => 'application/json'}
      request = Net::HTTP::Post.new(uri, header)
      request.body = MultiJson.encode(body)

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      parse_response(response)
    end

    def self.parse_response(response)
      case response.code.to_i
      when 200..204
        Lexer::Identity::EnrichedResult.from_json response.body
      when 400
        fail Lexer::Identity::BadRequestError, response.body
      when 401
        fail Lexer::Identity::AuthenticationError, response.body
      when 404
        fail Lexer::Identity::NotFoundError, response.body
      when 429
        fail Lexer::Identity::TooManyRequests, response.body
      when 409
        fail Lexer::Identity::LockError, response.body
      else
        fail Lexer::Identity::HttpError, response.body
      end
    end
  end # Module Identity
end # Module Lexer
