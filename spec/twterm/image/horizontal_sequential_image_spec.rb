require 'spec_helper'

RSpec.describe Twterm::Image::HorizontalSequentialImage do
  let(:image) { described_class.new([foo, ws, bar, ws, baz]) }
  let(:foo) { Twterm::Image::StringImage.new('foo') }
  let(:bar) { Twterm::Image::StringImage.new('bar') }
  let(:baz) { Twterm::Image::StringImage.new('baz') }
  let(:ws) { Twterm::Image::StringImage.new(' ') }

  describe '#to_s' do
    subject { image.to_s }

    it { is_expected.to eq 'foo bar baz' }
  end
end
