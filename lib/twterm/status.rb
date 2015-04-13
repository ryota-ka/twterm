module Twterm
  class Status
    MAX_CACHED_STATUSES_COUNT = 1000

    attr_reader :id, :text, :created_at, :created_at_for_sort, :retweet_count, :favorite_count, :in_reply_to_status_id, :favorited, :retweeted, :user, :retweeted_by, :urls, :media, :touched_at
    alias_method :favorited?, :favorited
    alias_method :retweeted?, :retweeted

    @@instances = {}

    def self.new(tweet)
      instance = find(tweet.id)
      instance.nil? ? super : instance.update!(tweet)
    end

    def initialize(tweet)
      unless tweet.retweeted_status.is_a? Twitter::NullObject
        @retweeted_by = User.new(tweet.user)
        retweeted_at = Status.parse_time(tweet.created_at)
        tweet = tweet.retweeted_status
      end

      @id = tweet.id
      @text = CGI.unescapeHTML(tweet.full_text.dup)
      @created_at = Status.parse_time(tweet.created_at)
      @created_at_for_sort = retweeted_at || @created_at
      @retweet_count = tweet.retweet_count
      @favorite_count = tweet.favorite_count
      @in_reply_to_status_id = tweet.in_reply_to_status_id

      @retweeted = tweet.retweeted?
      @favorited = tweet.favorited?

      @media = tweet.media
      @urls = tweet.urls

      @user = User.new(tweet.user)

      @splitted_text = {}

      expand_url!

      @touched_at = Time.now

      tweet.hashtags.each do |hashtag|
        History::Hashtag.instance.add(hashtag.text)
      end

      @@instances[id] = self
    end

    def update!(tweet)
      @retweet_count = tweet.retweet_count
      @favorite_count = tweet.favorite_count
      @retweeted = tweet.retweeted?
      @favorited = tweet.favorited?
      self
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

    def unfavorite!
      @favorite_count -= 1
      @favorited = false
    end

    def retweet!
      @retweet_count += 1
      @retweeted = true
    end

    def split(width)
      @splitted_text[:width] ||= @text.split_by_width(width)
    end

    def in_reply_to_status(&block)
      block.call(nil) if @in_reply_to_status_id.nil?

      status = Status.find(@in_reply_to_status_id)
      block.call(status) unless status.nil?

      Client.current.show_status(@in_reply_to_status_id, &block)
    end

    def touch!
      @touched_at = Time.now
    end

    def ==(other)
      other.is_a?(self.class) && id == other.id
    end

    class << self
      def all
        @@instances.values
      end

      def find(id)
        @@instances[id]
      end

      def parse_time(time)
        (time.is_a?(String) ? Time.parse(time) : time.dup).localtime
      end

      def cleanup
        count = MAX_CACHED_STATUSES_COUNT
        return if @@instances.count < count

        TabManager.instance.each_tab do |tab|
          tab.touch_statuses if tab.is_a?(Tab::StatusesTab)
        end
        statuses = @@instances.values.sort_by(&:touched_at).take(count)
        status_ids = statuses.map(&:id)
        @@instances = status_ids.zip(statuses).to_h
      end
    end
  end
end
