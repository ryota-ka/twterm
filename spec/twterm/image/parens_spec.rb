require 'spec_helper'

RSpec.describe Twterm::Image::Parens do
  let(:image) { described_class.new(foo) }
  let(:foo) { Twterm::Image::StringImage.new('foo') }

  describe '#to_s' do
    subject { image.to_s }

    it { is_expected.to eq '(foo)' }
  end
end
