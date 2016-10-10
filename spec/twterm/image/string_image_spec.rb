require 'spec_helper'

RSpec.describe Twterm::Image::StringImage do
  let(:image) { described_class.new(str) }
  let(:str) { 'Hello' }

  describe '#to_s' do
    subject { image.to_s }

    it { is_expected.to eq str }
  end
end
