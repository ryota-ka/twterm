RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = :random
end

Dir['spec/supports/**/*.rb'].each { |f| require File.expand_path(f, __dir__ + '/..') }

require 'twterm'
