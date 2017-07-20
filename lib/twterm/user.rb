module Twterm
  class User
    attr_reader :color, :description, :favorites_count, :followers_count,
                :friends_count, :id, :location, :name, :protected,
                :screen_name, :statuses_count, :verified, :website
    alias_method :protected?, :protected
    alias_method :verified?, :verified

    COLORS = [:red, :blue, :green, :cyan, :yellow, :magenta]

    def initialize(user)
      @id = user.id
      update!(user)
      @color = COLORS[@id % 6]
    end

    def update!(user)
      return self if recently_updated?

      @name = user.name
      @screen_name = user.screen_name
      @description = user.description.is_a?(Twitter::NullObject) ? '' : user.description
      @location = user.location.is_a?(Twitter::NullObject) ? '' : user.location
      @website = user.website
      @protected = user.protected?
      @statuses_count = user.statuses_count
      @favorites_count = user.favorites_count
      @friends_count = user.friends_count
      @followers_count = user.followers_count
      @verified = user.verified?

      @updated_at = Time.now

      self
    end

    private

    def recently_updated?
      !@updated_at.nil? && @updated_at + 60 > Time.now
    end
  end
end
