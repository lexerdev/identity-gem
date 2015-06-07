# encoding: utf-8

begin
  require 'bundler/setup'
rescue LoadError
  puts 'Use of Bundler is recommended'
end

require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/reporters'
require 'webmock/minitest'

require File.expand_path('../../lib/lexer', __FILE__)

Minitest::Reporters.use!(
  [Minitest::Reporters::SpecReporter.new],
  ENV,
  Minitest.backtrace_filter
)
