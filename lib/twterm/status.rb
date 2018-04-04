require 'concurrent'

require 'twterm/hashtag'

class Twitter::Tweet
  attr_reader :quoted_status_id

  def initialize(*args)
    @quoted_status_id = args[0][:quoted_status_id]
    super
  end
end

module Twterm
  class Status
    attr_reader :created_at, :favorite_count, :favorited, :hashtags, :id,
      :in_reply_to_status_id, :media, :retweet_count, :retweeted,
      :quoted_status_id, :retweeted_status_id, :text, :url, :urls, :user_id, :user_mentions
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
      @favorited = true
    end

    def initialize(tweet, is_retweeted_status = false)
      unless tweet.retweeted_status.is_a? Twitter::NullObject
        @retweeted_status_id = tweet.retweeted_status.id
      end

      @id = tweet.id
      text =
        if tweet.truncated? && tweet.attrs[:extended_tweet]
          tweet.attrs[:extended_tweet][:full_text]
        else
          tweet.attrs[:text] || tweet.attrs[:full_text]
        end
      @text = CGI.unescapeHTML(text)
      @created_at = tweet.created_at.dup.localtime
      @in_reply_to_status_id = tweet.in_reply_to_status_id
      @quoted_status_id = tweet.quoted_status_id
      @url = tweet.url

      update!(tweet, is_retweeted_status)

      @media = tweet.media
      @hashtags = tweet.hashtags.map { |tag| Hashtag.new(tag) }
      @urls = tweet.urls
      @user_mentions = tweet.user_mentions

      @user_id = tweet.user.id

      @splitted_text = {}

      expand_url!
    end

    def quote?
      !quoted_status_id.nil?
    end

    def retweet?
      !retweeted_status_id.nil?
    end

    def retweet!
      @retweeted = true
    end

    def split(width)
      @splitted_text[width] ||= @text.split_by_width(width)
    end

    def unfavorite!
      @favorited = false
    end

    def unretweet!
      @retweeted = false
    end

    def update!(tweet, is_retweeted_status = false)
      @retweet_count = tweet.retweet_count
      @favorite_count = tweet.favorite_count
      @retweeted = tweet.retweeted? unless is_retweeted_status
      @favorited = tweet.favorited?

      self
    end
  end
end
