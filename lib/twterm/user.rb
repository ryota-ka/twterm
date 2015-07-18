module Twterm
  class User
    attr_reader :id, :name, :screen_name, :description, :location, :website,
                :following, :protected, :statuses_count, :friends_count,
                :followers_count, :touched_at, :color
    alias_method :following?, :following
    alias_method :protected?, :protected

    MAX_CACHED_TIME = 3600
    COLORS = [:red, :blue, :green, :cyan, :yellow, :magenta]

    @@instances = {}

    def follow!
      @following = true
      self
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

    def touch!
      @touched_at = Time.now
    end

    def unfollow!
      @following = false
      self
    end

    def update!(user)
      @name = user.name
      @screen_name = user.screen_name
      @description = user.description || ''
      @location = user.location.is_a?(Twitter::NullObject) ? '' : user.location
      @website = user.website
      @following = user.following?
      @protected = user.protected?
      @statuses_count = user.statuses_count
      @friends_count = user.friends_count
      @followers_count = user.followers_count

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
      instance = find(id)
      (yield(instance) && return) if instance

      Client.current.show_user(id) { |user| yield user }
    end

    def self.cleanup
      referenced_users = Status.all.map(&:user)
      referenced_users.each(&:touch!)

      cond = -> (user) { user.touched_at > Time.now - MAX_CACHED_TIME }
      users = all.select(&cond)
      user_ids = users.map(&:id)
      @@instances = user_ids.zip(users).to_h
    end

    def self.new(user)
      instance = find(user.id)
      instance.nil? ? super : instance.update!(user)
    end
  end
end
