require 'twterm/key_mapper/abstract_key_mapper'

describe Twterm::KeyMapper::AbstractKeyMapper do
  describe '#translate' do
    subject { described_class.new({}).send(:translate, key) }

    before { described_class.define_singleton_method(:commands) { [] } }

    context 'when key is <C-a>' do
      let(:key) { '<C-a>' }

      it { is_expected.to eq 1 }
    end

    context 'when key is <C-A>' do
      let(:key) { '<C-A>' }

      it { is_expected.to eq 1 }
    end

    context 'when key is <Down>' do
      let(:key) { '<Down>' }

      it { is_expected.to eq Curses::Key::DOWN }
    end

    context 'when key is <Left>' do
      let(:key) { '<Left>' }

      it { is_expected.to eq Curses::Key::LEFT }
    end

    context 'when key is <Right>' do
      let(:key) { '<Right>' }

      it { is_expected.to eq Curses::Key::RIGHT }
    end

    context 'when key is <Up>' do
      let(:key) { '<Up>' }

      it { is_expected.to eq Curses::Key::UP }
    end

    context 'when key is <Space>' do
      let(:key) { '<Space>' }

      it { is_expected.to eq ' ' }
    end

    context 'when key is <Esc>' do
      let(:key) { '<Esc>' }

      it { is_expected.to eq 27 }
    end

    context 'when key is <F1>' do
      let(:key) { '<F1>' }

      it { is_expected.to eq Curses::Key::F1 }
    end

    context 'when key is <Backspace>' do
      let(:key) { '<Backspace>' }

      it { is_expected.to eq 127 }
    end
  end
end
