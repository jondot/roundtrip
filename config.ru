$:<< 'lib'

require 'roundtrip'
Roundtrip.options[:redis] = { :host  => 'localhost' }
Roundtrip.options[:statsd] = { :host => 'localhost', :port => 8125 }

require 'roundtrip/web'
run Roundtrip::Web

