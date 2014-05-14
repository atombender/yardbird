# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'yardbird/version'

Gem::Specification.new do |spec|
  spec.name          = "yardbird"
  spec.version       = Yardbird::VERSION
  spec.authors       = ["Alexander Staubo"]
  spec.email         = ["alex@bengler.no"]
  spec.summary       =
  spec.description   = %q{Yardbird produces REST API documentation from Yardoc comments in Ruby code, via Markdown.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'yard', '~> 0.8'
  spec.add_runtime_dependency 'yard-sinatra', '~> 1.0'
  spec.add_runtime_dependency 'mercenary', '~> 0.3'
  spec.add_runtime_dependency 'activesupport', '~> 4.0'

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
