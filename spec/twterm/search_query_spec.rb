describe Twterm::SearchQuery do
  describe '#empty?' do
    subject { query.empty? }

    context 'when empty' do
      let(:query) { described_class.new('') }

      it { is_expected.to eq true }
    end

    context 'when not empty' do
      let(:query) { described_class.new('twterm') }

      it { is_expected.to eq false }
    end
  end
end
