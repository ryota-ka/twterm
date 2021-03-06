require 'spec_helper'

RSpec.describe Twterm::Image::Color do
  let(:string_image) { Twterm::Image::StringImage.new(str) }
  let(:str) { 'Hello' }

  describe '#height' do
    subject { image.height }

    let(:image) { described_class.new(string_image, :red) }

    it { is_expected.to eq string_image.height }
  end

  describe '#to_s' do
    subject { image.to_s }

    context 'when only with foreground color' do
      let(:image) { described_class.new(string_image, :red) }

      it { is_expected.to eq "\e[31mHello\e[0m" }
    end

    context 'when with foreground and background color' do
      let(:image) { described_class.new(string_image, :red, :white) }

      it { is_expected.to eq "\e[47m\e[31mHello\e[0m" }
    end
  end

  describe '#width' do
    subject { image.width }

    let(:image) { described_class.new(string_image, :red) }

    it { is_expected.to eq string_image.width }
  end
end
