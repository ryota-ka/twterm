require 'twterm/user'

RSpec.describe Twterm::User do
  let(:user) { described_class.new(Twitter::User.new(json)) }
  let(:json) { JSON.parse(fixture('user.json'), symbolize_names: true) }

  describe '#update!' do
    subject { -> { user.update!(Hashie::Mash.new(params)) } }

    before do
      user.update!(Hashie::Mash.new(
        name: 'Alice',
        screen_name: 'alice',
        description: 'Hi! I am Alice.',
        location: 'Tokyo',
        website: 'http://example.com',
        protected?: false,
        statuses_count: 0,
        favorites_count: 0,
        friends_count: 0,
        followers_count: 0,
        verified?: false,
      ))
    end

    context 'when updating name' do
      let(:params) { { name: 'Bob' } }

      it { is_expected.to change { user.name }.from('Alice').to('Bob') }
    end

    context 'when updating screen_name' do
      let(:params) { { screen_name: 'bob' } }

      it { is_expected.to change { user.screen_name }.from('alice').to('bob') }
    end

    context 'when updating description' do
      let(:params) { { description: 'Hi! I am Bob.' } }

      it { is_expected.to change { user.description }.from('Hi! I am Alice.').to('Hi! I am Bob.') }
    end

    context 'when updating location' do
      context 'when location is empty' do
        let(:params) { { location: Twitter::NullObject.new } }

        it { is_expected.to change { user.location }.from('Tokyo').to('') }
      end

      context 'when location is present' do
        let(:params) { { location: 'New York' } }

        it { is_expected.to change { user.location }.from('Tokyo').to('New York') }
      end
    end

    context 'when updating website' do
      let(:params) { { website: 'https://example.com' } }

      it { is_expected.to change { user.website }.from('http://example.com').to('https://example.com') }
    end

    context 'when updating protected' do
      let(:params) { { protected?: true } }

      it { is_expected.to change { user.protected? }.from(false).to(true) }
    end

    context 'when updating statuses_count' do
      let(:params) { { statuses_count: 42 } }

      it { is_expected.to change { user.statuses_count }.from(0).to(42) }
    end

    context 'when updating favorites_count' do
      let(:params) { { favorites_count: 42 } }

      it { is_expected.to change { user.favorites_count }.from(0).to(42) }
    end

    context 'when updating followers_count' do
      let(:params) { { followers_count: 42 } }

      it { is_expected.to change { user.followers_count }.from(0).to(42) }
    end

    context 'when updating verified' do
      let(:params) { { verified?: true } }

      it { is_expected.to change { user.verified? }.from(false).to(true) }
    end
  end
end
