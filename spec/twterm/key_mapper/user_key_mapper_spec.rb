require 'spec_helper'

require 'twterm/key_mapper/user_key_mapper'

require_relative './../../supports/shared_examples/abstract_key_mapper'

RSpec.describe Twterm::KeyMapper::UserKeyMapper do
  it_behaves_like Twterm::KeyMapper::AbstractKeyMapper
end
