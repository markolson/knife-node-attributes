# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'knife-node-attributes/version'

Gem::Specification.new do |spec|
  spec.name          = "knife-node-attributes"
  spec.version       = Knife::NodeAttributes::VERSION
  spec.authors       = ["Mark Olson"]
  spec.email         = ["molson@lgscout.com"]
  spec.description   = %q{A Knife plugin that outputs converged node attributes in JSON.}
  spec.summary       = %q{Uses static node.json files, roles, environments, and cookbook attributes to generate a best-effort of what the node attributes will be for a run. Useful for generating documentation based on versions specified per node, role, or environment.}
  spec.homepage      = "http://github.com/lookingglass/knife-node-attributes"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency 'chef',     '>= 10.12'
end
