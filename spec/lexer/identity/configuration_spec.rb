# encoding: utf-8

require 'spec_helper'

describe Lexer::Identity do
  before do
    Lexer::Identity.configuration = nil
  end

  describe 'configuration setup' do
    it 'has valid defaults' do
      Lexer::Identity.configure {}

      config = Lexer::Identity.configuration

      config.api_url.must_equal 'https://identity.api.lexer.io/'
      config.api_token.must_be_nil
      config.consumer_token.must_be_nil
      config.contributor_token.must_be_nil
    end

    it 'sets configuration arguments' do
      Lexer::Identity.configure do |config|
        config.api_token = 'abc123'
        config.consumer_token = 'abc124'
        config.contributor_token = 'abc125'
      end

      config = Lexer::Identity.configuration

      config.api_url.must_equal 'https://identity.api.lexer.io/'
      config.api_token.must_equal 'abc123'
      config.consumer_token.must_equal 'abc124'
      config.contributor_token.must_equal 'abc125'
    end
  end # 'configuration setup'

  describe 'configuration validation' do
    it 'validates the presence of an API token' do
      Lexer::Identity.configure {}
      proc { Lexer::Identity.configuration.validate }.must_raise Lexer::Identity::ConfigurationError
    end

    it 'validates the presence of a contributor or consumer token' do
      Lexer::Identity.configure do |config|
        config.api_token = 'abc123'
      end
      proc { Lexer::Identity.configuration.validate }.must_raise Lexer::Identity::ConfigurationError
    end

    it 'validates the difference of a contributor or consumer token' do
      Lexer::Identity.configure do |config|
        config.api_token = 'abc123'
        config.contributor_token = 'abc123'
        config.consumer_token = 'abc123'
      end
      proc { Lexer::Identity.configuration.validate }.must_raise Lexer::Identity::ConfigurationError
    end
  end # 'configuration validation'
end
