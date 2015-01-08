require 'time'

class Status
  attr_reader :id, :text, :created_at, :retweet_count, :favorite_count, :user

  def initialize(tweet)
    @id = tweet.id
    @text = tweet.text
    @created_at = tweet.created_at.is_a?(String) ? Time.parse(tweet.created_at) : tweet.created_at
    @retweet_count = tweet.retweet_count
    @favorite_count = tweet.favorite_count

    @favorited = tweet.favorited?
    @retweeted = tweet.retweeted?

    @user = User.new(tweet.user)

    @splitted_text = {}
  end

  def favorited?
    @favorited
  end

  def retweeted?
    @retweeted
  end

  def favorite!
    @favorited = true
  end

  def split(width)
    @splitted_text[:width] ||= @text.split_by_width(width)
  end
end
