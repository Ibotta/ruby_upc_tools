# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'upc_tools/version'

Gem::Specification.new do |spec|
  spec.name          = "upc_tools"
  spec.version       = UpcTools::VERSION
  spec.authors       = ["Justin Hart", "Ibotta, Inc."]
  spec.email         = ["jhart@ibotta.com"]
  spec.summary       = %q{UPC validation and creation utilities}
  spec.description   = %q{create, validate, convert UPCs}
  spec.homepage      = "https://github.com/Ibotta/ruby_upc_tools"
  spec.licenses      = ['Apache-2.0']

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "yard"
end
