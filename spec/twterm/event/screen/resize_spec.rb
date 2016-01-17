require 'spec_helper'
require 'twterm/event/screen/resize'

RSpec.describe Twterm::Event::Screen::Resize do
  describe '#fields' do
    it 'has fields of Integer * Integer' do
      expect { described_class.new(5, 10) }.not_to raise_error
      expect { described_class.new('hello', 'world') }.to raise_error
    end
  end
end
