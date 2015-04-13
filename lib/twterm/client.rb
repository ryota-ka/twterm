module Twterm
  class Client
    attr_reader :user_id, :screen_name

    CREATE_STATUS_PROC = -> (s) { Status.new(s) }

    @@instances = []

    def initialize(user_id, screen_name, token, secret)
      @user_id = user_id
      @screen_name = screen_name

      @rest_client = Twitter::REST::Client.new do |config|
        config.consumer_key        = 'vLNSVFgXclBJQJRZ7VLMxL9lA'
        config.consumer_secret     = 'OFLKzrepRG2p1hq0nUB9j2S9ndFQoNTPheTpmOY0GYw55jGgS5'
        config.access_token        = token
        config.access_token_secret = secret
      end

      TweetStream.configure do |config|
        config.consumer_key       = 'vLNSVFgXclBJQJRZ7VLMxL9lA'
        config.consumer_secret    = 'OFLKzrepRG2p1hq0nUB9j2S9ndFQoNTPheTpmOY0GYw55jGgS5'
        config.oauth_token        = token
        config.oauth_token_secret = secret
        config.auth_method        = :oauth
      end

      @stream_client = TweetStream::Client.new

      @callbacks = {}
      @@instances << self
    end

    def stream
      @stream_client.on_friends do
        Notifier.instance.show_message 'Connection established'
      end

      @stream_client.on_timeline_status do |tweet|
        status = Status.new(tweet)
        invoke_callbacks(:timeline_status, status)
        invoke_callbacks(:mention, status) if status.text.include? "@#{@screen_name}"
      end

      @stream_client.on_delete do |status_id|
        timeline.delete_status(status_id)
      end

      @stream_client.on_event(:favorite) do |event|
        break if event[:source][:screen_name] == @screen_name
        message = "@#{event[:source][:screen_name]} has favorited your tweet: #{event[:target_object][:text]}"
        Notifier.instance.show_message(message)
      end

      @stream_client.on_no_data_received do
        connect_stream
      end

      connect_stream
    end

    def connect_stream
      @stream_client.stop_stream

      @streaming_thread = Thread.new do
        begin
          Notifier.instance.show_message 'Trying to connect to Twitter...'
          @stream_client.userstream
        rescue EventMachine::ConnectionError
          Notifier.instance.show_error 'Connection failed'
          sleep 30
          retry
        end
      end
    end

    def post(text, in_reply_to = nil)
      send_request do
        if in_reply_to.is_a? Status
          text = "@#{in_reply_to.user.screen_name} #{text}"
          @rest_client.update(text, in_reply_to_status_id: in_reply_to.id)
        else
          @rest_client.update(text)
        end
      end
    end

    def home_timeline
      send_request do
        yield @rest_client.home_timeline(count: 100).map(&CREATE_STATUS_PROC)
      end
    end

    def mentions
      send_request do
        yield @rest_client.mentions(count: 100).map(&CREATE_STATUS_PROC)
      end
    end

    def user_timeline(user_id)
      send_request do
        yield @rest_client.user_timeline(user_id, count: 100).map(&CREATE_STATUS_PROC)
      end
    end

    def lists
      send_request do
        yield @rest_client.lists.map { |list| List.new(list) }
      end
    end

    def list(list)
      fail ArgumentError, 'argument must be an instance of List class' unless list.is_a? List
      send_request do
        yield @rest_client.list_timeline(list.id, count: 100).map(&CREATE_STATUS_PROC)
      end
    end

    def search(query)
      send_request do
        yield @rest_client.search(query, count: 100).map(&CREATE_STATUS_PROC)
      end
    end

    def show_status(status_id)
      send_request do
        yield Status.new(@rest_client.status(status_id))
      end
    end

    def show_user(query)
      send_request do
        begin
          user = User.new(@rest_client.user(query))
        rescue Twitter::Error::NotFound
          user = nil
        end
        yield user
      end
    end

    def favorite(status)
      return false unless status.is_a? Status

      send_request do
        @rest_client.favorite(status.id)
        status.favorite!
        yield status if block_given?
      end

      self
    end

    def unfavorite(status)
      fail ArgumentError, 'argument must be an instance of Status class' unless status.is_a? Status

      send_request do
        @rest_client.unfavorite(status.id)
        status.unfavorite!
        yield status if block_given?
      end
    end

    def retweet(status)
      return false unless status.is_a? Status

      send_request do
        begin
          @rest_client.retweet!(status.id)
          status.retweet!
          yield status if block_given?
        rescue Twitter::Error::AlreadyRetweeted, Twitter::Error::NotFound, Twitter::Error::Forbidden
          Notifier.instance.show_error 'Retweet attempt failed'
        end
      end
    end

    def destroy_status(status)
      send_request do
        begin
          @rest_client.destroy_status(status.id)
          yield if block_given?
        rescue Twitter::Error::NotFound, Twitter::Error::Forbidden
          Notifier.instance.show_error 'You cannot destroy that status'
        end
      end
    end

    def on_timeline_status(&block)
      fail ArgumentError, 'no block given' unless block_given?
      on(:timeline_status, &block)
    end

    def on_mention(&block)
      fail ArgumentError, 'no block given' unless block_given?
      on(:mention, &block)
    end

    class << self
      def new(user_id, screen_name, token, secret)
        detector = -> (instance) { instance.user_id == user_id }
        instance = @@instances.find(&detector)
        instance.nil? ? super : instance
      end

      def current
        @@instances[0]
      end
    end

    private

    def on(event, &block)
      @callbacks[event] ||= []
      @callbacks[event] << block
      self
    end

    def invoke_callbacks(event, data = nil)
      return if @callbacks[event].nil?

      @callbacks[event].each { |cb| cb.call(data) }
      self
    end

    def send_request(&block)
      Thread.new do
        begin
          block.call
        rescue Twitter::Error => e
          Notifier.instance.show_error 'Failed to send request'
          sleep 10
          retry if e.message == 'getaddrinfo: nodename nor servname provided, or not known'
        end
      end
    end
  end
end
