module Twterm
  class User
    attr_reader :color, :description, :favorites_count, :followers_count,
                :friends_count, :id, :location, :name, :protected,
                :screen_name, :statuses_count, :touched_at, :verified, :website
    alias_method :protected?, :protected
    alias_method :verified?, :verified

    MAX_CACHED_TIME = 3600
    COLORS = [:red, :blue, :green, :cyan, :yellow, :magenta]

    @@instances = {}

    def blocked_by?(user_id)
      Friendship.blocking?(user_id, id)
    end

    def blocking?(user_id)
      Friendship.blocking?(id, user_id)
    end

    def followed_by?(user_id)
      Friendship.following?(user_id, id)
    end

    def following?(user_id)
      Friendship.following?(id, user_id)
    end

    def following_requested?(user_id)
      Friendship.following_requested?(id, user_id)
    end

    def following_requested_by?(user_id)
      Friendship.following_requested?(user_id, id)
    end

    def initialize(user)
      @id = user.id
      update!(user)
      @color = COLORS[@id % 6]
      touch!

      @@instances[@id] = self
    end

    def matches?(query)
      [name, screen_name, description, website].any? { |x| x.to_s.downcase.include? query.downcase }
    end

    def muted_by?(user_id)
      Friendship.muting?(user_id, id)
    end

    def muting?(user_id)
      Friendship.muting?(id, user_id)
    end

    def touch!
      @touched_at = Time.now
    end

    def update!(user)
      @name = user.name
      @screen_name = user.screen_name
      @description = user.description || ''
      @location = user.location.is_a?(Twitter::NullObject) ? '' : user.location
      @website = user.website
      @protected = user.protected?
      @statuses_count = user.statuses_count
      @favorites_count = user.favorites_count
      @friends_count = user.friends_count
      @followers_count = user.followers_count
      @verified = user.verified?

      client_id = Client.current.user_id

      if user.following?
        Friendship.follow(client_id, user.id)
      else
        Friendship.unfollow(client_id, user.id)
      end

      if user.follow_request_sent?
        Friendship.following_requested(client_id, user.id)
      else
        Friendship.following_not_requested(client_id, user.id)
      end

      History::ScreenName.instance.add(user.screen_name)

      self
    end

    def self.all
      @@instances.values
    end

    def self.find(id)
      @@instances[id]
    end

    def self.find_or_fetch(id)
      Promise.new do |resolve, reject|
        instance = find(id)
        (resolve.(instance) && next) if instance

        Client.current.show_user(id).then do |user|
          resolve.(user)
        end
      end
    end

    def self.cleanup
      referenced_users = Status.all.map(&:user)
      referenced_users.each(&:touch!)

      cond = -> (user) { user.touched_at > Time.now - MAX_CACHED_TIME }
      users = all.select(&cond)
      user_ids = users.map(&:id)
      @@instances = user_ids.zip(users).to_h
    end

    def self.ids
      @@instances.keys
    end

    def self.new(user)
      instance = find(user.id)
      instance.nil? ? super : instance.update!(user)
    end
  end
end
