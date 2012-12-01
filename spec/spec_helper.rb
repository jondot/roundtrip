$: << File.expand_path('../lib', File.dirname(__FILE__))
require 'rr'
require 'roundtrip'
require 'minitest/autorun'
require 'timecop'

class MiniTest::Unit::TestCase
  include RR::Adapters::MiniTest
end


