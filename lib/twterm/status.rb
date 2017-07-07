require 'concurrent'

module Twterm
  class Status
    MAX_CACHED_TIME = 3600

    attr_reader :appeared_at, :created_at, :favorite_count, :favorited, :id,
      :in_reply_to_status_id, :media, :retweet_count, :retweeted,
      :retweeted_by_user_id, :text, :urls, :user_id
    alias_method :favorited?, :favorited
    alias_method :retweeted?, :retweeted

    def ==(other)
      other.is_a?(self.class) && id == other.id
    end

    def date
      format = Time.now - @created_at < 86_400 ? '%H:%M:%S' : '%Y-%m-%d %H:%M:%S'
      @created_at.strftime(format)
    end

    def expand_url!
      sub = -> (x) { @text.sub!(x.url, x.display_url) }
      (@media + @urls).each(&sub)
    end

    def favorite!
      @favorite_count += 1
      @favorited = true
    end

    def initialize(tweet)
      unless tweet.retweeted_status.is_a? Twitter::NullObject
        @retweeted_by_user_id = tweet.user.id
        App.instance.user_repository.create(tweet.user)
        retweeted_at = tweet.created_at.dup.localtime
        tweet = tweet.retweeted_status
      end

      @id = tweet.id
      @text = CGI.unescapeHTML(tweet.full_text.dup)
      @created_at = tweet.created_at.dup.localtime
      @appeared_at = retweeted_at || @created_at
      @retweet_count = tweet.retweet_count
      @favorite_count = tweet.favorite_count
      @in_reply_to_status_id = tweet.in_reply_to_status_id

      @retweeted = tweet.retweeted?
      @favorited = tweet.favorited?

      @media = tweet.media
      @urls = tweet.urls

      @user_id = tweet.user.id
      App.instance.user_repository.create(tweet.user)

      @splitted_text = {}

      expand_url!
    end

    def retweet!
      @retweet_count += 1
      @retweeted = true
    end

    def retweeted_by
      App.instance.user_repository.find(@retweeted_by_user_id)
    end

    def split(width)
      @splitted_text[width] ||= @text.split_by_width(width)
    end

    def unfavorite!
      @favorite_count -= 1
      @favorited = false
    end

    def update!(tweet)
      return self if recently_updated?

      @retweet_count = tweet.retweet_count
      @favorite_count = tweet.favorite_count
      @retweeted = tweet.retweeted?
      @favorited = tweet.favorited?

      @updated_at = Time.now

      self
    end

    def user
      App.instance.user_repository.find(user_id)
    end

    private

    def recently_updated?
      !@updated_at.nil? && @updated_at + 60 > Time.now
    end
  end
end
