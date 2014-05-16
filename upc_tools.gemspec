# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'upc_tools/version'

Gem::Specification.new do |spec|
  spec.name          = "upc_tools"
  spec.version       = UpcTools::VERSION
  spec.authors       = ["Justin Hart"]
  spec.email         = ["jhart@onyxraven.com"]
  spec.summary       = %q{UPC validation and creation utilities}
  spec.description   = %q{create, validate, convert UPCs}
  spec.homepage      = "https://github.com/Ibotta/ruby_upc_tools"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard-rspec"

end
