class User
  attr_reader :id, :name, :screen_name, :description, :location, :url, :statuses_count, :friends_count, :followers_count

  def initialize(user)
    @id = user.id
    @name = user.name
    @screen_name = user.screen_name
    @description = user.description || ''

    @location = user.location
    @url = user.url

    @following = user.following?
    @protected = user.protected?

    @statuses_count = user.statuses_count
    @friends_count = user.friends_count
    @followers_count = user.followers_count
  end

  def following?
    @following
  end

  def protected?
    @protected
  end
end
