require_relative "lib/rolistic/version"

Gem::Specification.new do |spec|
  spec.name          = "rolistic"
  spec.version       = Rolistic::VERSION
  spec.authors       = ["Carl Zulauf"]
  spec.email         = ["carl@linkleaf.com"]

  spec.summary       = %q{Role based permissions}
  spec.description   = %q{Simple DSL to define roles and associated permissions.}
  spec.homepage      = "https://github.com/carlzulauf/rolistic"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.3"

  spec.metadata = {
    "source_code_uri"       => spec.homepage,
    "bug_tracker_uri"       => "#{spec.homepage}/issues",
    "rubygems_mfa_required" => "true",
  }

  spec.files         = Dir["lib/**/*.rb"] + %w(README.md LICENSE.txt)
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.13"
end
