# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'roundtrip/version'

Gem::Specification.new do |gem|
  gem.name          = "roundtrip"
  gem.version       = Roundtrip::VERSION
  gem.authors       = ["Dotan Nahum"]
  gem.email         = ["jondotan@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "thor"
  gem.add_dependency "sinatra"
  gem.add_dependency "redis-namespace"
  gem.add_dependency "redis"
  gem.add_dependency "json"
  gem.add_dependency "ratom"
  gem.add_dependency "thor"
  gem.add_dependency "statsd-ruby"

  gem.add_development_dependency "guard-minitest"
  gem.add_development_dependency "rr"
  gem.add_development_dependency "timecop"

end
