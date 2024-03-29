# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'outdated/version'

Gem::Specification.new do |spec|
  spec.name          = 'outdated'
  spec.version       = Outdated::VERSION
  spec.authors       = ['Keith Broughton']
  spec.email         = ['keith.broughton@fatzebra.com.au']

  spec.summary       = 'Safely update your gems'
  spec.description   = 'Safely update your gems'
  spec.homepage      = 'https://github.com/keithbro/outdated'
  spec.license       = 'MIT'

  spec.metadata['allowed_push_host'] = "https://rubygems.org"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = 'https://github.com/keithbro/outdated'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = %w[outdated]
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'bundler', '~> 1.7'
  spec.add_dependency 'http', '~> 4.1.1'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
end
