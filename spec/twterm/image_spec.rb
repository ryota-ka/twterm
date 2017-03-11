require 'twterm/image'

RSpec.describe Twterm::Image do
  describe '.number' do
    subject { described_class.number(n) }

    context 'when n = 42' do
      let(:n) { 42 }

      it 'is stringified as it is' do
        expect(subject.to_s).to eq '42'
      end
    end

    context 'when n = 1000000' do
      let(:n) { 1_000_000 }

      it 'is formatted with commas' do
        expect(subject.to_s).to eq '1,000,000'
      end
    end
  end
end
