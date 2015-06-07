# Lexer Identities Official Ruby Client Library

[![Build Status](https://travis-ci.org/lexerdev/identity-gem.svg)](http://travis-ci.org/lexerdev/identity-gem)
[![Code Climate](https://codeclimate.com/github/lexerdev/identity-gem/badges/gpa.svg)](https://codeclimate.com/github/lexerdev/identity-gem)

Lexer Identity Gem is the official Ruby Client for the [Lexer Identity](https://lexer.io/) API. The
Lexer Identity API lets brands contribute and consume from Lexer's Identity database directly from their apps.

## Installation

Add to your Gemfile:

    gem 'lexer-identity'

or install from Rubygems:

    gem install lexer-identity


## Details

### Links:

Have a limited list of keys which can be reviewed at: http://developer.lexer.io/
Your hash should reflect the following format:

    {
      email: "joe.smith@mybrand.com",
      phone: "61440000000",
      twitter: "camplexer"
    }

Multiple values can be provided via arrays:

    {
      email: ["joe.smith@mybrand.com", "j.smith@mybrand.com"],
      phone: "61440000000",
      twitter: "camplexer"
    }

### Attributes:

Need to be defined by the valid namespace which should be provided
to you along with your tokens.
An attribute namespace is defined by: `com.brand.*` where `com.brand`
is defined along with your tokens and `*` can be replaced with any
`A-Za-z0-9._-` character.

Your attribute hash should reflect the following format:

    {
      "com.brand.email" => "joe.smith@mybrand.com",
      "com.brand.phone" => "61440000000",
      "com.brand.twitter" => "camplexer"
    }

Permitted values include:

- String
- Numbers
- Arrays
- Simple Hashes

Attribute hashes are transported via JSON so any format supported
by JSON is supported by Lexer.

