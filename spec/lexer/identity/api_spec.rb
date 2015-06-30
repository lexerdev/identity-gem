# encoding: utf-8
require 'spec_helper'

describe Lexer::Identity do
  describe 'constants' do
    it 'has required constants' do
      Lexer::Identity::CONFIDENCE_PROVIDED.wont_be_nil
      Lexer::Identity::CONFIDENCE_CALCULATED.wont_be_nil
      Lexer::Identity::CONFIDENCE_INFERRED.wont_be_nil
    end
  end

  describe 'use of links and ids' do
    before do
      Lexer::Identity.configuration = nil
      Lexer::Identity.configure do |config|
        config.api_token = 'abc-123'
        config.contributor_token = 'bcd-234'
        config.consumer_token = 'cde-345'
      end
    end

    it 'requires either a link or id' do
      proc do
        Lexer::Identity.enrich
      end.must_raise Lexer::Identity::MissingLinksError
    end

    it 'requires at least one link' do
      proc do
        Lexer::Identity.enrich(
          links: {}
        )
      end.must_raise Lexer::Identity::MissingLinksError
    end

    it 'produces a valid request with links' do
      stub_request(:post, 'https://identity.api.lexer.io/').
        with(body: '{"links":{"email":["user1@brand.com","usera@brand.com"],"mobile":"61440000000"},"api_token":"abc-123","contributor_token":"bcd-234","consumer_token":"cde-345"}', headers: { 'Content-Type' => 'application/json' }).
        to_return(status: 200, body: '{"id":"0a224111-ac64-4142-9198-adf8bf2c1a04"}')

      Lexer::Identity.enrich(
        links: {
          email: %w(user1@brand.com usera@brand.com),
          mobile: '61440000000'
        }
      )

      assert_requested(:post, 'https://identity.api.lexer.io/', times: 1)
    end

    it 'produces a valid request with an ID' do
      stub_request(:post, 'https://identity.api.lexer.io/').
        with(body: '{"id":"0a224111-ac64-4142-9198-adf8bf2c1a04","api_token":"abc-123","contributor_token":"bcd-234","consumer_token":"cde-345"}', headers: { 'Content-Type' => 'application/json' }).
        to_return(status: 200, body: '{"id":"0a224111-ac64-4142-9198-adf8bf2c1a04"}')

      Lexer::Identity.enrich(
        id: '0a224111-ac64-4142-9198-adf8bf2c1a04'
      )

      assert_requested(:post, 'https://identity.api.lexer.io/', times: 1)
    end

    it 'ignores links when an ID is present' do
      stub_request(:post, 'https://identity.api.lexer.io/').
        with(body: '{"id":"0a224111-ac64-4142-9198-adf8bf2c1a04","api_token":"abc-123","contributor_token":"bcd-234","consumer_token":"cde-345"}', headers: { 'Content-Type' => 'application/json' }).
        to_return(status: 200, body: '{"id":"0a224111-ac64-4142-9198-adf8bf2c1a04"}')

      Lexer::Identity.enrich(
        id: '0a224111-ac64-4142-9198-adf8bf2c1a04',
        links: {
          email: %w(user1@brand.com usera@brand.com),
          mobile: '61440000000'
        }
      )

      assert_requested(:post, 'https://identity.api.lexer.io/', times: 1)
    end
  end

  describe 'contributions' do
    before do
      Lexer::Identity.configuration = nil
      Lexer::Identity.configure do |config|
        config.api_token = 'abc-123'
        config.contributor_token = 'bcd-234'
      end
    end

    describe 'attribute payloads' do
      it 'requires a complete payload' do
        proc do
          Lexer::Identity.enrich(
            id: 'abc-123',
            attributes: {
              'com.brand.car' => 'Tesla'
            }
          )
        end.must_raise Lexer::Identity::AttributePayloadError

        proc do
          Lexer::Identity.enrich(
            id: 'abc-123',
            attributes: {
              'com.brand.car' => {
                value: 'attribute value'
              }
            }
          )
        end.must_raise Lexer::Identity::AttributePayloadError

        proc do
          Lexer::Identity.enrich(
            id: 'abc-123',
            attributes: {
              'com.brand.car' => {
                confidence: Lexer::Identity::CONFIDENCE_PROVIDED
              }
            }
          )
        end.must_raise Lexer::Identity::AttributePayloadError
      end

      it 'accepts values as strings, numbers, arrays and hashes' do
        stub_request(:post, "https://identity.api.lexer.io/").
          with(body: '{"id":"0a224111-ac64-4142-9198-adf8bf2c1a04","attributes":{"com.brand.string":{"value":"Tesla","confidence":2},"com.brand.number":{"value":100,"confidence":2},"com.brand.array":{"value":["a","b"],"confidence":2},"com.brand.hash":{"value":{"klass":"hash"},"confidence":2}},"api_token":"abc-123","contributor_token":"bcd-234"}').
          to_return(status: 200, body: '{"id":"0a224111-ac64-4142-9198-adf8bf2c1a04"}')

        Lexer::Identity.enrich(
          id: '0a224111-ac64-4142-9198-adf8bf2c1a04',
          attributes: {
            'com.brand.string' => {
              value: 'Tesla',
              confidence: Lexer::Identity::CONFIDENCE_PROVIDED
            },
            'com.brand.number' => {
              value: 100,
              confidence: Lexer::Identity::CONFIDENCE_PROVIDED
            },
            'com.brand.array' => {
              value: ["a", "b"],
              confidence: Lexer::Identity::CONFIDENCE_PROVIDED
            },
            'com.brand.hash' => {
              value: { klass: 'hash' },
              confidence: Lexer::Identity::CONFIDENCE_PROVIDED
            }
          }
        )

        assert_requested(:post, 'https://identity.api.lexer.io/', times: 1)
      end

      it 'accepts symbols or string keys' do
        stub_request(:post, 'https://identity.api.lexer.io/').
          with(body: '{"id":"0a224111-ac64-4142-9198-adf8bf2c1a04","attributes":{"com.brand.car":{"value":"Tesla","confidence":2}},"api_token":"abc-123","contributor_token":"bcd-234"}', headers: { 'Content-Type' => 'application/json' }).
          to_return(status: 200, body: '{"id":"0a224111-ac64-4142-9198-adf8bf2c1a04"}')

        Lexer::Identity.enrich(
          id: '0a224111-ac64-4142-9198-adf8bf2c1a04',
          attributes: {
            'com.brand.car' => {
              value: 'Tesla',
              confidence: Lexer::Identity::CONFIDENCE_PROVIDED
            }
          }
        )

        Lexer::Identity.enrich(
          id: '0a224111-ac64-4142-9198-adf8bf2c1a04',
          attributes: {
            'com.brand.car' => {
              'value' => 'Tesla',
              'confidence' => Lexer::Identity::CONFIDENCE_PROVIDED
            }
          }
        )

        assert_requested(:post, 'https://identity.api.lexer.io/', times: 2)
      end

      it 'allows a complete payload' do
        stub_request(:post, 'https://identity.api.lexer.io/').
          with(body: '{"id":"0a224111-ac64-4142-9198-adf8bf2c1a04","attributes":{"com.brand.car":{"value":"Tesla","confidence":2}},"api_token":"abc-123","contributor_token":"bcd-234"}', headers: { 'Content-Type' => 'application/json' }).
          to_return(status: 200, body: '{"id":"0a224111-ac64-4142-9198-adf8bf2c1a04"}')

        Lexer::Identity.enrich(
          id: '0a224111-ac64-4142-9198-adf8bf2c1a04',
          attributes: {
            'com.brand.car' => {
              value: 'Tesla',
              confidence: Lexer::Identity::CONFIDENCE_PROVIDED
            }
          }
        )

        assert_requested(:post, 'https://identity.api.lexer.io/', times: 1)
      end

      it 'allows a metadata payload' do
        stub_request(:post, 'https://identity.api.lexer.io/').
          with(body: '{"id":"0a224111-ac64-4142-9198-adf8bf2c1a04","attributes":{"com.brand.car":{"value":"Tesla","confidence":2,"metadata":{"extra":"data"}}},"api_token":"abc-123","contributor_token":"bcd-234"}', headers: { 'Content-Type' => 'application/json' }).
          to_return(status: 200, body: '{"id":"0a224111-ac64-4142-9198-adf8bf2c1a04"}')

        Lexer::Identity.enrich(
          id: '0a224111-ac64-4142-9198-adf8bf2c1a04',
          attributes: {
            'com.brand.car' => {
              value: 'Tesla',
              confidence: Lexer::Identity::CONFIDENCE_PROVIDED,
              metadata: {
                extra: "data"
              }
            }
          }
        )

        assert_requested(:post, 'https://identity.api.lexer.io/', times: 1)
      end
    end

    it 'returns an EnrichedResult' do
      stub_request(:post, 'https://identity.api.lexer.io/').
        with(body: '{"links":{"email":"user1@brand.com"},"attributes":{"com.brand.car":{"value":"Tesla","confidence":2}},"api_token":"abc-123","contributor_token":"bcd-234"}', headers: { 'Content-Type' => 'application/json' }).
        to_return(status: 200, body: '{"id":"0a224111-ac64-4142-9198-adf8bf2c1a04"}')

      result = Lexer::Identity.enrich(
        links: {
          email: 'user1@brand.com'
        },
        attributes: {
          'com.brand.car' => {
            value: 'Tesla',
            confidence: Lexer::Identity::CONFIDENCE_PROVIDED
          }
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
      stub_request(:post, 'https://identity.api.lexer.io/').
        with(body: '{"links":{"email":["user1@brand.com","usera@brand.com"],"mobile":"61440000000"},"api_token":"abc-123","consumer_token":"bcd-234"}', headers: { 'Content-Type' => 'application/json' }).
        to_return(status: 200, body: '{"id":"0a224111-ac64-4142-9198-adf8bf2c1a04","attributes":{"com.brand.car":{"value":"Tesla","confidence":2},"com.brand.code":{"value":10,"confidence":2},"com.brand.products":{"value":["a","b","c"],"confidence":1},"com.brand.detail":{"value":{"make":"cake"},"confidence":0}}}')

      Lexer::Identity.enrich(
        links: {
          email: %w(user1@brand.com usera@brand.com),
          mobile: '61440000000'
        },
        attributes: {
          'com.brand.car' => {
            value: 'Tesla',
            confidence: Lexer::Identity::CONFIDENCE_PROVIDED
          }
        }
      )

      assert_requested(:post, 'https://identity.api.lexer.io/', times: 1)
    end

    it 'returns an EnrichedResult' do
      stub_request(:post, 'https://identity.api.lexer.io/').
        with(body: '{"links":{"email":["user1@brand.com","usera@brand.com"],"mobile":"61440000000"},"api_token":"abc-123","consumer_token":"bcd-234"}', headers: { 'Content-Type' => 'application/json' }).
        to_return(status: 200, body: '{"id":"0a224111-ac64-4142-9198-adf8bf2c1a04","attributes":{"com.brand.car":{"value":"Tesla","confidence":2},"com.brand.code":{"value":10,"confidence":2},"com.brand.products":{"value":["a","b","c"],"confidence":1},"com.brand.detail":{"value":{"make":"cake"},"confidence":0}}}')

      result = Lexer::Identity.enrich(
        links: {
          email: %w(user1@brand.com usera@brand.com),
          mobile: '61440000000'
        },
        attributes: {
          'com.brand.car' => {
            value: 'Tesla',
            confidence: Lexer::Identity::CONFIDENCE_PROVIDED
          }
        }
      )

      result.must_be_instance_of Lexer::Identity::EnrichedResult
      result.id.must_be_kind_of String
      hash = {
        'com.brand.car' => {
          'value' => 'Tesla',
          'confidence' => 2
        },
        'com.brand.code' => {
          'value' => 10,
          'confidence' => 2
        },
        'com.brand.products' => {
          'value' => %w(a b c),
          'confidence' => 1
        },
        'com.brand.detail' => {
          'value' => { 'make' => 'cake' },
          'confidence' => 0
        }
      }
      result.attributes.must_equal hash
    end
  end

end
