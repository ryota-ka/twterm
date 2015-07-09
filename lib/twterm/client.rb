module Twterm
  class Client
    attr_reader :user_id, :screen_name

    CREATE_STATUS_PROC = -> (s) { Status.new(s) }
    CONSUMER_KEY = 'vLNSVFgXclBJQJRZ7VLMxL9lA'.freeze
    CONSUMER_SECRET = 'OFLKzrepRG2p1hq0nUB9j2S9ndFQoNTPheTpmOY0GYw55jGgS5'.freeze

    @@instances = []

    def connect_stream
      stream_client.stop_stream

      @streaming_thread = Thread.new do
        begin
          Notifier.instance.show_message 'Trying to connect to Twitter...'
          stream_client.userstream
        rescue EventMachine::ConnectionError
          Notifier.instance.show_error 'Connection failed'
          sleep 30
          retry
        end
      end
    end

    def destroy_status(status)
      send_request do
        begin
          rest_client.destroy_status(status.id)
          yield if block_given?
        rescue Twitter::Error::NotFound, Twitter::Error::Forbidden
          Notifier.instance.show_error 'You cannot destroy that status'
        end
      end
    end

    def favorite(status)
      return false unless status.is_a? Status

      send_request do
        rest_client.favorite(status.id)
        status.favorite!
        yield status if block_given?
      end

      self
    end

    def fetch_muted_users
      send_request do
        @muted_user_ids = rest_client.muted_ids.to_a
        yield @muted_user_ids if block_given?
      end
    end

    def home_timeline
      send_request do
        statuses = rest_client
          .home_timeline(count: 100)
          .select(&@mute_filter)
          .map(&CREATE_STATUS_PROC)
        yield statuses
      end
    end

    def initialize(user_id, screen_name, access_token, access_token_secret)
      @user_id, @screen_name = user_id, screen_name
      @access_token, @access_token_secret = access_token, access_token_secret

      @callbacks = {}

      @mute_filter = -> _ { true }
      fetch_muted_users do |muted_user_ids|
        @mute_filter = lambda do |status|
          !muted_user_ids.include?(status.user.id) &&
            !(status.retweeted_status.is_a?(Twitter::NullObject) &&
            muted_user_ids.include?(status.retweeted_status.user.id))
        end
      end

      @@instances << self
    end

    def list(list_id)
      send_request do
        yield List.new(rest_client.list(list_id))
      end
    end

    def list_timeline(list)
      fail ArgumentError,
        'argument must be an instance of List class' unless list.is_a? List
      send_request do
        statuses = rest_client
          .list_timeline(list.id, count: 100)
          .select(&@mute_filter)
          .map(&CREATE_STATUS_PROC)
        yield statuses
      end
    end

    def lists
      send_request do
        yield rest_client.lists.map { |list| List.new(list) }
      end
    end

    def mentions
      send_request do
        statuses = rest_client
          .mentions(count: 100)
          .select(&@mute_filter)
          .map(&CREATE_STATUS_PROC)
        yield statuses
      end
    end

    def on_mention(&block)
      fail ArgumentError, 'no block given' unless block_given?
      on(:mention, &block)
    end

    def on_timeline_status(&block)
      fail ArgumentError, 'no block given' unless block_given?
      on(:timeline_status, &block)
    end

    def post(text, in_reply_to = nil)
      send_request do
        if in_reply_to.is_a? Status
          text = "@#{in_reply_to.user.screen_name} #{text}"
          rest_client.update(text, in_reply_to_status_id: in_reply_to.id)
        else
          rest_client.update(text)
        end
      end
    end

    def rest_client
      @rest_client ||= Twitter::REST::Client.new do |config|
        config.consumer_key        = CONSUMER_KEY
        config.consumer_secret     = CONSUMER_SECRET
        config.access_token        = @access_token
        config.access_token_secret = @access_token_secret
      end
    end

    def retweet(status)
      fail ArgumentError,
        'argument must be an instance of Status class' unless status.is_a? Status

      send_request do
        begin
          rest_client.retweet!(status.id)
          status.retweet!
          yield status if block_given?
        rescue => e
          message =
            case e
            when Twitter::Error::AlreadyRetweeted
              'The status is already retweeted'
            when Twitter::Error::NotFound
              'The status is not found'
            when Twitter::Error::Forbidden
              if status.user.id == user_id  # when the status is mine
                'You cannot retweet your own status'
              else  # when the status is not mine
                'The status is protected'
              end
            else
              raise e
            end
          Notifier.instance.show_error "Retweet attempt failed: #{message}"
        end
      end
    end

    def saved_search
      send_request do
        yield rest_client.saved_searches
      end
    end

    def search(query)
      send_request do
        statuses = rest_client
          .search(query, count: 100)
          .select(&@mute_filter)
          .map(&CREATE_STATUS_PROC)
        yield statuses
      end
    end

    def show_status(status_id)
      send_request do
        yield Status.new(rest_client.status(status_id))
      end
    end

    def show_user(query)
      send_request do
        user =
          begin
            User.new(rest_client.user(query))
          rescue Twitter::Error::NotFound
            nil
          end
        yield user
      end
    end

    def stream
      stream_client.on_friends do
        Notifier.instance.show_message 'Connection established' unless @stream_connected
        @stream_connected = true
      end

      stream_client.on_timeline_status do |tweet|
        status = Status.new(tweet)
        invoke_callbacks(:timeline_status, status)
        invoke_callbacks(:mention, status) if status.text.include? "@#{@screen_name}"
      end

      stream_client.on_delete do |status_id|
        timeline.delete_status(status_id)
      end

      stream_client.on_event(:favorite) do |event|
        break if event[:source][:screen_name] == @screen_name

        user = event[:source][:screen_name]
        text = event[:target_object][:text]
        message = "@#{user} has favorited your tweet: #{text}"
        Notifier.instance.show_message(message)
      end

      stream_client.on_no_data_received do
        @stream_connected = false
        connect_stream
      end

      connect_stream
    end

    def stream_client
      @stream_client ||= TweetStream::Client.new(
        consumer_key:       CONSUMER_KEY,
        consumer_secret:    CONSUMER_SECRET,
        oauth_token:        @access_token,
        oauth_token_secret: @access_token_secret,
        auth_method:        :oauth
      )
    end

    def unfavorite(status)
      fail ArgumentError,
        'argument must be an instance of Status class' unless status.is_a? Status

      send_request do
        rest_client.unfavorite(status.id)
        status.unfavorite!
        yield status if block_given?
      end
    end

    def user_timeline(user_id)
      send_request do
        statuses = rest_client
          .user_timeline(user_id, count: 100)
          .select(&@mute_filter)
          .map(&CREATE_STATUS_PROC)
        yield statuses
      end
    end

    def self.new(user_id, screen_name, token, secret)
      detector = -> (instance) { instance.user_id == user_id }
      instance = @@instances.find(&detector)
      instance.nil? ? super : instance
    end

    def self.current
      @@instances[0]
    end

    private

    def invoke_callbacks(event, data = nil)
      return if @callbacks[event].nil?

      @callbacks[event].each { |cb| cb.call(data) }
      self
    end

    def on(event, &block)
      @callbacks[event] ||= []
      @callbacks[event] << block
      self
    end

    def send_request(&block)
      Thread.new do
        begin
          block.call
        rescue Twitter::Error => e
          Notifier.instance.show_error "Failed to send request: #{e.message}"
          if e.message == 'getaddrinfo: nodename nor servname provided, or not known'
            sleep 10
            retry
          end
        end
      end
    end
  end
end
