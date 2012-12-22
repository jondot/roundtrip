require "roundtrip/version"

module Roundtrip
  def self.options
    @options ||= {}
  end
end


require 'roundtrip/trip'
require 'roundtrip/core'
require 'roundtrip/store'
require 'roundtrip/metrics'



