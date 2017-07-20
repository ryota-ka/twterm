require 'hashie/mash'

describe Twterm::Status do
  let(:status) { described_class.new(Twitter::Tweet.new(json)) }
  let(:json) { JSON.parse(fixture('status.json'), symbolize_names: true) }

  describe '#==' do
    subject { status === other }

    context 'when having the same id' do
      let(:other) { status.dup }

      it { is_expected.to be true }
    end

    context 'when having different id' do
      let(:other) { json[:id] = 42; described_class.new(Twitter::Tweet.new(json)) }

      it { is_expected.to be false }
    end

    context 'when not being an instance of Twterm::Status' do
      let(:other) { :foo }

      it { is_expected.to be false }
    end
  end

  describe '#favorite!' do
    subject { -> { status.favorite! } }

    before { status.update!(Hashie::Mash.new(favorite_count: 0, favorited: false)) }

    it { is_expected.to change { status.favorite_count }.by 1 }
    it { is_expected.to change { status.favorited? }.from(false).to(true) }
  end

  describe '#retweet!' do
    subject { -> { status.retweet! } }

    before { status.update!(Hashie::Mash.new(retweet_count: 0, retweeted: false)) }

    it { is_expected.to change { status.retweet_count }.by 1 }
    it { is_expected.to change { status.retweeted? }.from(false).to(true) }
  end

  describe '#update!' do
    subject { -> { status.update!(Hashie::Mash.new(params)) } }

    before { status.update!(Hashie::Mash.new(retweet_count: 0, favorite_count: 0, retweeted: false, favorited: false)) }

    context 'when updating retweet_count' do
      let(:params) { { retweet_count: 42 } }

      it { is_expected.to change { status.retweet_count }.from(0).to(42) }
    end

    context 'when updating favorite_count' do
      let(:params) { { favorite_count: 42 } }

      it { is_expected.to change { status.favorite_count }.from(0).to(42) }
    end

    context 'when updating retweeted' do
      let(:params) { { retweeted: true } }

      it { is_expected.to change { status.retweeted? }.from(false).to(true) }
    end

    context 'when updating favorited' do
      let(:params) { { favorited: true } }

      it { is_expected.to change { status.favorited? }.from(false).to(true) }
    end
  end
end
