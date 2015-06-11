# Lexer Identities Official Ruby Client Library

[![Build Status](https://travis-ci.org/lexerdev/identity-gem.svg)](http://travis-ci.org/lexerdev/identity-gem)
[![Code Climate](https://codeclimate.com/github/lexerdev/identity-gem/badges/gpa.svg)](https://codeclimate.com/github/lexerdev/identity-gem)
[![Gem Version](https://badge.fury.io/rb/lexer-identity.svg)](http://badge.fury.io/rb/lexer-identity)

Lexer Identity Gem is the official Ruby Client for the [Lexer Identity](https://lexer.io/) API. The
Lexer Identity API lets brands contribute and consume from Lexer's Identity database directly from their apps.


## Installation

Add to your Gemfile:

    gem 'lexer-identity'

or install from Rubygems:

    gem install lexer-identity

And include it in your project as:

    require 'lexer'


## Use

    # Configure using the provided tokens
    Lexer::Identity.configure do |config|
      config.api_token = "..."
      config.contributor_token = "..."
      config.consumer_token = "..."
    end
  
    # Communicate via the enrich method
    Lexer::Identity.enrich( links: { email: "test@lexer.io", twitter: "camplexer" }, attributes: { "io.lexer.name": { value: "Jane Smith", confidence: Lexer::Identity::CONFIDENCE_PROVIDED, ... } )

## Further Reading

See the full documentation at http://developer.lexer.io.
