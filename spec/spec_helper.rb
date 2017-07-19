RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = :random
end

def fixture(path)
  dir = File.expand_path('../fixtures', __FILE__)
  File.read("#{dir}/#{path}")
end

Dir['spec/supports/**/*.rb'].each { |f| require File.expand_path(f, __dir__ + '/..') }

require 'twterm'
