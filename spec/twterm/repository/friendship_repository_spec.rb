require 'twterm/repository/friendship_repository'

RSpec.describe Twterm::Repository::FriendshipRepository do
  let(:repository) { described_class.new }

  describe '#already_looked_up?' do
    before do
      repository.looked_up!(1)
    end

    it 'returns true when the user is already looked up' do
      expect(repository.already_looked_up?(1)).to be true
    end

    it 'returns false when the user is not looked up yet' do
      expect(repository.already_looked_up?(2)).to be false
    end
  end

  describe '#blocking?' do
    before do
      repository.block(1, 2)
    end

    it 'returns true when user 1 blocks user 2' do
      expect(repository.blocking?(1, 2)).to be true
    end

    it 'returns false when user 1 does not block user 2' do
      expect(repository.blocking?(2, 1)).to be false
    end
  end

  describe '#following?' do
    before do
      repository.follow(1, 2)
    end

    it 'returns true when user 1 follows user 2' do
      expect(repository.following?(1, 2)).to be true
    end

    it 'returns false when user 1 does not follow user 2' do
      expect(repository.following?(2, 1)).to be false
    end
  end

  describe '#following_requested?' do
    before do
      repository.following_requested(1, 2)
    end

    it 'returns true when user 1 have sent following request to user 2' do
      expect(repository.following_requested?(1, 2)).to be true
    end

    it 'returns false when user 1 have not sent following request to user 2' do
      expect(repository.following_requested?(2, 1)).to be false
    end
  end

  describe '#muting?' do
    before do
      repository.mute(1, 2)
    end

    it 'returns true when user 1 mutes user 2' do
      expect(repository.muting?(1, 2)).to be true
    end

    it 'returns false when user 1 does not mute user 2' do
      expect(repository.muting?(2, 1)).to be false
    end
  end

  describe '#unblock' do
    before do
      repository.block(1, 2)
    end

    it 'works' do
      repository.unblock(1, 2)
      expect(repository.blocking?(1, 2)).to be false
    end
  end

  describe '#unfollow' do
    before do
      repository.follow(1, 2)
    end

    it 'works' do
      repository.unfollow(1, 2)
      expect(repository.following?(1, 2)).to be false
    end
  end

  describe '#unmute' do
    before do
      repository.mute(1, 2)
    end

    it 'works' do
      repository.unmute(1, 2)
      expect(repository.muting?(1, 2)).to be false
    end
  end
end
