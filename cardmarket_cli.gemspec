# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'cardmarket_cli/version'

Gem::Specification.new do |spec|
  spec.name          = 'cardmarket_cli'
  spec.version       = CardmarketCLI::VERSION
  spec.authors       = ['lisstem']
  spec.email         = ['kontakt@knuddelkrabbe.de']

  spec.summary       = 'CLI for cardmarket.com'
  # spec.description   = 'TODO: Write a longer description or delete this line.'
  spec.homepage      = 'https://github.com/Lisstem/cardmarket-cli'
  spec.license       = 'BlueOak-1.0.0'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.1')

  # spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  # spec.metadata['changelog_uri'] = "TODO: Put your gem's CHANGELOG.md URL here."

  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'oauth', '~> 0.5.5'
  spec.add_dependency 'typhoeus', '~> 1.4'
  spec.add_dependency 'xml-simple', '~> 1.1'

  spec.add_development_dependency 'guard', '~> 2.16.2'
  spec.add_development_dependency 'guard-minitest', '~> 2.4.6'
  spec.add_development_dependency 'minitest', '~> 5.13.0'
  spec.add_development_dependency 'minitest-reporters', '~> 1.4.3'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rubocop', '~> 1.7'
  spec.add_development_dependency 'rubocop-minitest', '~> 0.10.3'
  spec.add_development_dependency 'rubocop-rake', '~> 0.5.1'
end
