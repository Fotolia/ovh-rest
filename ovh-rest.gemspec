# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "ovh-rest"
  spec.version       = "0.0.1"
  spec.authors       = ["Jonathan Amiez"]
  spec.email         = ["jonathan.amiez@fotolia.com"]
  spec.description   = "OVH REST API interface"
  spec.summary       = "Manage OVH services from Ruby"
  spec.homepage      = "https://github.com/Fotolia/ovh-rest"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
end
