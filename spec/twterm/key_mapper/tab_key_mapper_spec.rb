require 'spec_helper'

require 'twterm/key_mapper/tab_key_mapper'

RSpec.describe Twterm::KeyMapper::TabKeyMapper do
  it_behaves_like Twterm::KeyMapper::AbstractKeyMapper
end
