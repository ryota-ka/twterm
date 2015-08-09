describe Twterm::Friendship do
  describe '.already_looked_up?' do
    before do
      described_class.looked_up!(1)
    end

    it 'returns true when the user is already looked up' do
      expect(described_class.already_looked_up?(1)).to be true
    end

    it 'returns false when the user is not looked up yet' do
      expect(described_class.already_looked_up?(2)).to be false
    end
  end

  describe '.blocking?' do
    before do
      described_class.block(1, 2)
    end

    it 'returns true when user 1 blocks user 2' do
      expect(described_class.blocking?(1, 2)).to be true
    end

    it 'returns false when user 1 does not block user 2' do
      expect(described_class.blocking?(2, 1)).to be false
    end
  end

  describe '.following?' do
    before do
      described_class.follow(1, 2)
    end

    it 'returns true when user 1 follows user 2' do
      expect(described_class.following?(1, 2)).to be true
    end

    it 'returns false when user 1 does not follow user 2' do
      expect(described_class.following?(2, 1)).to be false
    end
  end

  describe '.following_requested?' do
    before do
      described_class.following_requested(1, 2)
    end

    it 'returns true when user 1 have sent following request to user 2' do
      expect(described_class.following_requested?(1, 2)).to be true
    end

    it 'returns false when user 1 have not sent following request to user 2' do
      expect(described_class.following_requested?(2, 1)).to be false
    end
  end

  describe '.muting?' do
    before do
      described_class.mute(1, 2)
    end

    it 'returns true when user 1 mutes user 2' do
      expect(described_class.muting?(1, 2)).to be true
    end

    it 'returns false when user 1 does not mute user 2' do
      expect(described_class.muting?(2, 1)).to be false
    end
  end

  describe '.unblock' do
    before do
      described_class.block(1, 2)
    end

    it 'works' do
      described_class.unblock(1, 2)
      expect(described_class.blocking?(1, 2)).to be false
    end
  end

  describe '.unfollow' do
    before do
      described_class.follow(1, 2)
    end

    it 'works' do
      described_class.unfollow(1, 2)
      expect(described_class.following?(1, 2)).to be false
    end
  end

  describe '.unmute' do
    before do
      described_class.mute(1, 2)
    end

    it 'works' do
      described_class.unmute(1, 2)
      expect(described_class.muting?(1, 2)).to be false
    end
  end
end
