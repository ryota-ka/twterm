class User
  attr_reader :id, :name, :screen_name, :description, :location, :website, :following, :protected, :statuses_count, :friends_count, :followers_count
  attr_reader :color
  alias_method :following?, :following
  alias_method :protected?, :protected

  COLORS = [:red, :blue, :green, :cyan, :yellow, :magenta]

  def initialize(user)
    @id = user.id
    @name = user.name
    @screen_name = user.screen_name
    @description = user.description || ''

    @location = user.location.is_a?(String) ? user.location : ''
    @website = user.website

    @following = user.following?
    @protected = user.protected?

    @statuses_count = user.statuses_count
    @friends_count = user.friends_count
    @followers_count = user.followers_count

    @color = COLORS[@id % 6]
  end
end
