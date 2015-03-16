lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'twterm/version'

Gem::Specification.new do |spec|
  spec.name          = 'twterm'
  spec.version       = Twterm::VERSION
  spec.authors       = ['Ryota Kameoka']
  spec.email         = ['kameoka.ryota@gmail.com']

  spec.summary       = 'A full-featured CLI Twitter client'
  spec.description   = 'A full-featured CLI Twitter client'
  spec.homepage      = 'http://twterm.ryota-ka.me/'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |i| i == 'Gemfile.lock' }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'curses', '>= 1.0.1'
  spec.add_dependency 'launchy', '>= 2.4.3'
  spec.add_dependency 'oauth', '>= 0.4.7'
  spec.add_dependency 'tweetstream', '>= 2.6.1'
  spec.add_dependency 'twitter', '>= 5.14.0'

  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'rake', '~> 10.0'
end
