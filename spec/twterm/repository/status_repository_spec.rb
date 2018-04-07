require 'twterm/repository/status_repository'
require 'twterm/repository/user_repository'

RSpec.describe Twterm::Repository::StatusRepository do
  let(:repository) { described_class.new }
  let(:tweet) { Twitter::Tweet.new(json) }
  let(:json) { JSON.parse(fixture('status.json'), symbolize_names: true) }

  it 'can be instantiated' do
    expect(described_class.new).to be_a described_class
  end

  it 'creates and stores an status' do
    expect { repository.create(tweet) }.to change {
      repository.find(tweet.id)
    }.from(nil).to be_a Twterm::Status
  end

  describe '#after_create' do
    let(:receiver) { double('receiver') }

    before { allow(receiver).to receive(:do_something) }

    context 'when no hook is registered' do
      it 'invokes no hooks' do
        expect(receiver).not_to receive :do_something

        repository.create(tweet)
      end
    end

    context 'when a hook is registered' do
      before { repository.after_create { receiver.do_something } }

      it 'invokes the registered hook' do
        expect(receiver).to receive :do_something

        repository.create(tweet)
      end
    end
  end

  describe '#before_create' do
    let(:receiver) { double('receiver') }

    before { allow(receiver).to receive(:do_something) }

    context 'when no hook is registered' do
      it 'invokes no hooks' do
        expect(receiver).not_to receive :do_something

        repository.create(tweet)
      end
    end

    context 'when a hook is registered' do
      before { repository.before_create { receiver.do_something } }

      it 'invokes the registered hook' do
        expect(receiver).to receive :do_something

        repository.create(tweet)
      end
    end
  end

  describe '#find' do
    subject { repository.find(id) }

    let(:id) { tweet.id }

    context 'when there are no statuses in the repository' do
      it { is_expected.to be_nil }
    end

    context 'when there is a status having the same id' do
      before { repository.create(tweet) }

      it { is_expected.to be_a Twterm::Status }
    end
  end

  context 'when integrated with user_repository' do
    let(:user_repository) { Twterm::Repository::UserRepository.new }

    before { repository.before_create { |tweet| user_repository.create(tweet.user) } }

    it 'also creates a user in user repository when creating a new status' do
      expect { repository.create(tweet) }
        .to change { user_repository.all.count }.by(1)
    end
  end
end
