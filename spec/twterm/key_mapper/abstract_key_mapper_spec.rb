require 'twterm/key_mapper/abstract_key_mapper'

describe Twterm::KeyMapper::AbstractKeyMapper do
  describe '#translate' do
    subject { described_class.new({}).send(:translate, key) }

    before { described_class.define_singleton_method(:commands) { [] } }

    context 'when key is ^A' do
      let(:key) { '^A' }

      it { is_expected.to eq 1 }
    end

    context 'when key is F1' do
      let(:key) { 'F1' }

      it { is_expected.to eq Curses::Key::F1 }
    end
  end
end
