module Twterm
  class User
    attr_reader :description, :favorites_count, :followers_count,
                :friends_count, :id, :location, :name, :protected,
                :screen_name, :statuses_count, :url, :verified, :website
    alias_method :protected?, :protected
    alias_method :verified?, :verified

    def initialize(user)
      @id = user.id
      update!(user)
    end

    def update!(user)
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
      @url = user.url
      @verified = user.verified?

      self
    end
  end
end
