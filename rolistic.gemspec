# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rolistic/version'

Gem::Specification.new do |spec|
  spec.name          = "rolistic"
  spec.version       = Rolistic::VERSION
  spec.authors       = ["Carl Zulauf"]
  spec.email         = ["carl@linkleaf.com"]

  spec.summary       = %q{Role based permissions}
  spec.description   = %q{Simple DSL to define roles and associated permissions.}
  spec.homepage      = "https://github.com/carlzulauf/rolistic"
  spec.license       = "MIT"

  spec.files         = `git ls-files -- lib/*`.split("\n")
  spec.files        += %w(README.md LICENSE.txt)
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.13"
end
