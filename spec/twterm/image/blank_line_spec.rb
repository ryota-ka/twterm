require 'spec_helper'

RSpec.describe Twterm::Image::BlankLine do
  let(:image) { described_class.new }

  describe '#to_s' do
    subject { image.to_s }

    it { is_expected.to eq "\n" }
  end
end
