require 'spec_helper'

RSpec.describe Twterm::Image::Empty do
  let(:image) { described_class.new }

  describe '#to_s' do
    subject { image.to_s }

    it { is_expected.to eq '' }
  end
end
