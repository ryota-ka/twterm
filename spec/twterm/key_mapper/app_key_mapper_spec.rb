require 'spec_helper'

require 'twterm/key_mapper/app_key_mapper'

RSpec.describe Twterm::KeyMapper::AppKeyMapper do
  it_behaves_like Twterm::KeyMapper::AbstractKeyMapper
end
