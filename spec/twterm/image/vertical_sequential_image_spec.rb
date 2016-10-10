require 'spec_helper'

RSpec.describe Twterm::Image::VerticalSequentialImage do
  let(:image) { described_class.new([foo, bar, baz]) }
  let(:foo) { Twterm::Image::StringImage.new('foo') }
  let(:bar) { Twterm::Image::StringImage.new('bar') }
  let(:baz) { Twterm::Image::StringImage.new('baz') }

  describe '#to_s' do
    subject { image.to_s }

    it { is_expected.to eq "foo\nbar\nbaz"}
  end
end
