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
  spec.required_ruby_version = spec.required_ruby_version = Gem::Requirement.new('~> 2.5')

  spec.add_dependency 'curses', '~> 1.4.0'
  spec.add_dependency 'concurrent-ruby', '~> 1.1.7'
  spec.add_dependency 'launchy', '~> 2.5.0'
  spec.add_dependency 'oauth', '~> 0.5.1'
  spec.add_dependency 'terminal-notifier', '~> 2.0.0'
  spec.add_dependency 'toml-rb', '~> 2.0.1'
  spec.add_dependency 'twitter', '~> 7.0.0'
  spec.add_dependency 'twitter-text', '~> 3.1.0'
end
