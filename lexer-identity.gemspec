# encoding: utf-8
$:.push File.expand_path('../lib', __FILE__)
require 'lexer/identity/version'

Gem::Specification.new do |s|
  s.name        = 'lexer-identity'
  s.version     = Lexer::Identity::VERSION
  s.authors     = ['Aaron Wallis']
  s.email       = 'code@Lexer.io'
  s.homepage    = 'https://github.com/lexerdev/lexer-identity-api.gem'
  s.summary     = 'Lexer Identity API Client'
  s.description = 'Consume and Contribute Identity data from your Ruby applications.'

  s.add_dependency 'multi_json', '~> 1.3'

  s.files         = `git ls-files`.split('\n')
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split('\n')
  s.executables   = `git ls-files -- bin/*`.split('\n').map { |f| File.basename(f) }
  s.require_paths = ['lib']
end
