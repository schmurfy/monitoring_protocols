# -*- encoding: utf-8 -*-
require File.expand_path('../lib/monitoring_protocols/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Julien Ammous"]
  gem.email         = ["schmurfy@gmail.com"]
  gem.description   = %q{...}
  gem.summary       = %q{....}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.name          = "monitoring_protocols"
  gem.require_paths = ["lib"]
  gem.version       = MonitoringProtocols::VERSION
  
  gem.add_dependency 'msgpack'
  gem.add_dependency 'oj',      '~> 2.1.4'
end
