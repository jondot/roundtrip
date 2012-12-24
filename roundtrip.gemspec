# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'roundtrip/version'

Gem::Specification.new do |gem|
  gem.name          = "roundtrip"
  gem.version       = Roundtrip::VERSION
  gem.authors       = ["Dotan Nahum"]
  gem.email         = ["jondotan@gmail.com"]
  gem.description   = %q{Simple business process/transactions tracking and metrics service}
  gem.summary       = %q{Simple business process/transactions tracking and metrics service}
  gem.homepage      = "https://github.com/jondot/roundtrip"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "thor"
  gem.add_dependency "sinatra"
  gem.add_dependency "redis-namespace"
  gem.add_dependency "redis"
  gem.add_dependency "json"
  gem.add_dependency "thor"
  gem.add_dependency "statsd-ruby"
  gem.add_dependency "ffi-rzmq"
  gem.add_dependency "nokogiri"

  gem.add_development_dependency "minitest"
  gem.add_development_dependency "guard-minitest"
  gem.add_development_dependency "rr"
  gem.add_development_dependency "timecop"

end
