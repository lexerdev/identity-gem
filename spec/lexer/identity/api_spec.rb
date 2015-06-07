# encoding: utf-8
require 'spec_helper'

describe Lexer::Identity do
  describe 'contributions' do
    before do
      Lexer::Identity.configuration = nil
      Lexer::Identity.configure do |config|
        config.api_token = 'abc-123'
        config.contributor_token = 'bcd-234'
      end
    end
    it 'produces a valid request' do
      stub_request(:post, 'https://identity.lexer.io/identity')
        .with(body: '{"links":{"email":["user1@brand.com","usera@brand.com"],"mobile":"61440000000"},"attributes":{"com.brand.car":"Tesla","com.brand.code":10,"com.brand.products":["a","b","c"],"com.brand.detail":{"make":"cake"}},"api_token":"abc-123","contributor_token":"bcd-234"}', headers: { 'Content-Type' => 'application/json' })
        .to_return(status: 200, body: '{"id":"0a224111-ac64-4142-9198-adf8bf2c1a04"}')

      Lexer::Identity.enrich(
        links: {
          email: %w(user1@brand.com usera@brand.com),
          mobile: '61440000000'
        }, attributes: {
          'com.brand.car': 'Tesla',
          'com.brand.code': 10,
          'com.brand.products': %w(a b c),
          'com.brand.detail': { make: 'cake' }
        }
      )

      assert_requested(:post, 'https://identity.lexer.io/identity', times: 1)
    end
    it 'returns an EnrichedResult' do
      stub_request(:post, 'https://identity.lexer.io/identity')
        .with(body: '{"links":{"email":"user1@brand.com"},"attributes":{"com.brand.car":"Tesla"},"api_token":"abc-123","contributor_token":"bcd-234"}', headers: { 'Content-Type' => 'application/json' })
        .to_return(status: 200, body: '{"id":"0a224111-ac64-4142-9198-adf8bf2c1a04"}')

      result = Lexer::Identity.enrich(
        links: {
          email: 'user1@brand.com'
        }, attributes: {
          'com.brand.car': 'Tesla'
        }
      )

      result.must_be_instance_of Lexer::Identity::EnrichedResult
      result.id.must_be_kind_of String
      result.attributes.must_be_nil
    end
  end

  describe 'consumptions' do
    before do
      Lexer::Identity.configuration = nil
      Lexer::Identity.configure do |config|
        config.api_token = 'abc-123'
        config.consumer_token = 'bcd-234'
      end
    end
    it 'produces a valid request' do
      stub_request(:post, 'https://identity.lexer.io/identity')
        .with(body: '{"links":{"email":["user1@brand.com","usera@brand.com"],"mobile":"61440000000"},"api_token":"abc-123","consumer_token":"bcd-234"}', headers: { 'Content-Type' => 'application/json' })
        .to_return(status: 200, body: '{"id":"0a224111-ac64-4142-9198-adf8bf2c1a04","attributes":{"com.brand.car":"Tesla","com.brand.code":10,"com.brand.products":["a","b","c"],"com.brand.detail":{"make":"cake"}}}')

      Lexer::Identity.enrich(
        links: {
          email: %w(user1@brand.com usera@brand.com),
          mobile: '61440000000'
        }, attributes: {
          'com.brand.car': 'Tesla' # note: this will be discarded as consumers can't contribute
        }
      )

      assert_requested(:post, 'https://identity.lexer.io/identity', times: 1)
    end
    it 'returns an EnrichedResult' do
      stub_request(:post, 'https://identity.lexer.io/identity')
        .with(body: '{"links":{"email":["user1@brand.com","usera@brand.com"],"mobile":"61440000000"},"api_token":"abc-123","consumer_token":"bcd-234"}', headers: { 'Content-Type' => 'application/json' })
        .to_return(status: 200, body: '{"id":"0a224111-ac64-4142-9198-adf8bf2c1a04","attributes":{"com.brand.car":"Tesla","com.brand.code":10,"com.brand.products":["a","b","c"],"com.brand.detail":{"make":"cake"}}}')

      result = Lexer::Identity.enrich(
        links: {
          email: %w(user1@brand.com usera@brand.com),
          mobile: '61440000000'
        }, attributes: {
          'com.brand.car': 'Tesla' # note: this will be discarded as consumers can't contribute
        }
      )

      result.must_be_instance_of Lexer::Identity::EnrichedResult
      result.id.must_be_kind_of String
      hash = { 'com.brand.car' => 'Tesla', 'com.brand.code' => 10, 'com.brand.products' => %w(a b c), 'com.brand.detail' => { 'make' => 'cake' } }
      result.attributes.must_equal hash
    end
  end
end
