module Twterm
  class User
    attr_reader :id, :name, :screen_name, :description, :location, :website, :following, :protected, :statuses_count, :friends_count, :followers_count
    attr_reader :color
    alias_method :following?, :following
    alias_method :protected?, :protected

    COLORS = [:red, :blue, :green, :cyan, :yellow, :magenta]

    @@instances = []

    def self.new(user)
      detector = -> (instance) { instance.id == user.id }
      instance = @@instances.find(&detector)
      instance.nil? ? super : instance.update!(user)
    end

    def initialize(user)
      @id = user.id
      update!(user)
      @color = COLORS[@id % 6]

      @@instances << self
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
      self
    end
  end
end
