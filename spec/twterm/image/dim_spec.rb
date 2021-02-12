require 'spec_helper'

RSpec.describe Twterm::Image::Dim do
  let(:string_image) { Twterm::Image::StringImage.new(str) }
  let(:str) { 'Hello' }

  describe '#height' do
    subject { image.height }

    let(:image) { described_class.new(string_image) }

    it { is_expected.to eq string_image.height }
  end

  describe '#to_s' do
    subject { image.to_s }

    let(:image) { described_class.new(string_image) }

    it { is_expected.to eq "\e[2mHello\e[0m" }
  end

  describe '#width' do
    subject { image.width }

    let(:image) { described_class.new(string_image) }

    it { is_expected.to eq string_image.width }
  end
end
