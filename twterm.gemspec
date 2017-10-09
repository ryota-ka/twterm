lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'twterm/version'

Gem::Specification.new do |spec|
  spec.name          = 'twterm'
  spec.version       = Twterm::VERSION
  spec.authors       = ['Ryota Kameoka']
  spec.email         = ['kameoka.ryota@gmail.com']

  spec.summary       = 'A full-featured TUI Twitter client'
  spec.description   = 'A full-featured TUI Twitter client'
  spec.homepage      = 'http://twterm.ryota-ka.me/'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |i| i == 'Gemfile.lock' }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.1.0'

  spec.add_dependency 'curses', '~> 1.2.2'
  spec.add_dependency 'concurrent-ruby', '~> 1.0.5'
  spec.add_dependency 'launchy', '~> 2.4.3'
  spec.add_dependency 'oauth', '~> 0.5.1'
  spec.add_dependency 'toml-rb', '~> 0.3.14'
  spec.add_dependency 'twitter', '~> 6.1.0'
  spec.add_dependency 'twitter-text', '1.14.5'

  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'hashie', '~> 3.5.6'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec', '~> 3.5.0'
end
