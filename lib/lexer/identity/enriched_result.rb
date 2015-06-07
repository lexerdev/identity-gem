# encoding: utf-8
require 'multi_json'

# :nordoc:
module Lexer
  # :nordoc:
  module Identity
    # The treturned result of an +Lexer::Identity.enrich+ request.
    # Contains accessors for the returned +id+ and +attributes+.
    class EnrichedResult
      attr_accessor :id
      attr_accessor :attributes

      def initialize(args)
        args.each do |k, v|
          instance_variable_set("@#{k}", v) unless v.nil?
        end
      end

      def self.from_json(json)
        data = MultiJson.decode(json)
        Lexer::Identity::EnrichedResult.new(data)
      end
    end
  end
end
