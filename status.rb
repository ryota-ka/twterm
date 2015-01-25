require 'time'

class Status
  attr_reader :id, :text, :created_at, :retweet_count, :favorite_count, :favorited, :retweeted, :user
  alias_method :favorited?, :favorited
  alias_method :retweeted?, :retweeted

  def initialize(tweet)
    @id = tweet.id
    @text = CGI.unescapeHTML(tweet.full_text.dup)
    @created_at = (tweet.created_at.is_a?(String) ? Time.parse(tweet.created_at) : tweet.created_at.dup).localtime
    @retweet_count = tweet.retweet_count
    @favorite_count = tweet.favorite_count

    @favorited = tweet.favorited?
    @retweeted = tweet.retweeted?

    @media = tweet.media
    @urls = tweet.urls

    @user = User.new(tweet.user)

    @splitted_text = {}

    expand_url!
  end

  def date
    format = Time.now - @created_at < 86_400 ? '%H:%M:%S' : '%Y-%m-%d %H:%M:%S'
    @created_at.strftime(format)
  end

  def expand_url!
    @media.each { |medium| @text.sub!(medium.url, medium.display_url) }
    @urls.each { |url| @text.sub!(url.url, url.display_url) }
  end

  def favorite!
    @favorited = true
  end

  def unfavorite!
    @favorited = false
  end

  def retweet!
    @retweeted = true
  end

  def split(width)
    @splitted_text[:width] ||= @text.split_by_width(width)
  end
end
