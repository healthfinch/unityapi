# -*- encoding: utf-8 -*-
require File.expand_path('../lib/unityapi/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "unityapi"
  gem.version       = UnityAPI::VERSION
  gem.authors       = ["Ash Gupta"]
  gem.email         = ["ash.gupta@healthfinch.com"]
  gem.description   = %q{Unity Enterprise API wrapper}
  gem.summary       = %q{This is a ruby wrapper for the Allscripts Unity Enterprise API}
  gem.homepage      = ""
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.add_runtime_dependency 'savon', '>= 1.0.0'
  gem.require_paths = ["lib"]

end
