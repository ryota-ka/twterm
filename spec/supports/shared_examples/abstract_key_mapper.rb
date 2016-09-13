RSpec.shared_examples Twterm::KeyMapper::AbstractKeyMapper do
  describe '.commands' do
    subject { described_class.commands }

    it { is_expected.to be_an Array }

    it { is_expected.to all be_kind_of Symbol }
  end

  describe '.category' do
    subject { described_class.category }

    it { is_expected.to be_an String }
  end
end
