# encoding: utf-8
$:.push File.expand_path('../lib', __FILE__)
require 'lexer/identity/version'

Gem::Specification.new do |s|
  s.name        = 'lexer-identity'
  s.version     = Lexer::Identity::VERSION
  s.platform    = Gem::Platform::RUBY
  s.licenses    = ['MIT']
  s.authors     = ['Aaron Wallis']
  s.email       = 'code@Lexer.io'
  s.homepage    = 'https://github.com/lexerdev/identity-gem'
  s.summary     = 'Lexer Identity API Client'
  s.description = 'Consume and Contribute Identity data from your Ruby applications.'

  s.add_dependency 'multi_json', '~> 1.3'

  s.files = `git ls-files`.split($RS).reject do |file|
    file =~ %r{^(?:
    spec/.*
    |Gemfile
    |Rakefile
    |\.gitignore
    |\.rubocop.yml
    |\.travis.yml
    )$}x
  end
  s.test_files    = `git ls-files`.split($RS)
  s.require_paths = ['lib']
end
