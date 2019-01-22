# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/appload/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-appload'
  spec.version       = Fastlane::Appload::VERSION
  spec.author        = ["Boris Bügling", "Felix Krause"]
  spec.email         = %q{boris@icculus.org}

  spec.summary       = %q{Generate required load sizes and loadset from a master application load.}
  spec.homepage      = "https://github.com/KrauseFx/fastlane-plugin-appload"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'mini_magick', '~> 4.5.1'
  spec.add_dependency 'json'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'fastlane', '>= 1.95.0'
end
