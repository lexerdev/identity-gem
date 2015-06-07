# encoding: utf-8

require 'spec_helper'

describe Lexer::Identity do
  describe 'versioning' do
    it 'returns a version' do
      Lexer::Identity::VERSION.wont_be_nil
    end
  end

  describe 'logger' do
    it 'should be set to info' do
      Lexer::Identity.logger.level.must_equal Logger::INFO
    end
  end
end
