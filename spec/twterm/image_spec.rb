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

  describe '.plural' do
    context 'the plural form is not given' do
      subject { described_class.plural(n, 'image') }

      context 'when n = 1' do
        let(:n) { 1 }

        it 'returns the singular form' do
          expect(subject.to_s).to eq 'image'
        end
      end

      context 'when n = 42' do
        let(:n) { 42 }

        it 'returns the plural form' do
          expect(subject.to_s).to eq 'images'
        end
      end
    end

    context 'the plural form is explicitly given' do
      subject { described_class.plural(n, 'index', 'indices') }

      context 'when n = 1' do
        let(:n) { 1 }

        it 'returns the singular form' do
          expect(subject.to_s).to eq 'index'
        end
      end

      context 'when n = 42' do
        let(:n) { 42 }

        it 'returns the plural form' do
          expect(subject.to_s).to eq 'indices'
        end
      end
    end
  end
end
