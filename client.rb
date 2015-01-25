require 'bundler'
Bundler.require

class Client
  private_class_method :new

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
  end

  def stream
    @stream_client.on_timeline_status do |tweet|
      status = Status.new(tweet)
      invoke_callbacks(:timeline_status, status)
      invoke_callbacks(:mention, status) if status.text.include? "@#{@screen_name}"
    end

    @stream_client.on_delete do |status_id|
      timeline.delete_status(status_id)
    end

    @stream_client.on_event(:favorite) do |event|
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
    @streaming_thread.kill if @streaming_thread.is_a? Thread

    loop do
      Notifier.instance.show_message 'Trying to connect to Twitter...'
      begin
        @streaming_thread = Thread.new do
          @stream_client.userstream
        end
        break
      rescue EventMachine::ConnectionError
        Notifier.instance.show_error 'Connection failed'
        sleep 30
      end
    end
    Notifier.instance.show_message 'Connection established'
  end

  def post(text, in_reply_to = nil)
    Thread.new do
      if in_reply_to.is_a? Status
        text = "@#{in_reply_to.user.screen_name} #{text}"
        @rest_client.update(text, in_reply_to_status_id: in_reply_to.id)
      else
        @rest_client.update(text)
      end
    end
  end

  def home_timeline
    Thread.new do
      yield @rest_client.home_timeline(count: 200).map { |tweet| Status.new(tweet) }
    end
  end

  def mentions
    Thread.new do
      yield @rest_client.mentions(count: 200).map { |tweet| Status.new(tweet) }
    end
  end

  def user_timeline(user_id)
    @rest_client.user_timeline(user_id).map { |tweet| Status.new(tweet) }
  end

  def lists
    Thread.new do
      yield @rest_client.lists.map { |list| List.new(list) }
    end
  end

  def list(list)
    fail ArgumentError, 'argument must be an instance of List class' unless list.is_a? List
    Thread.new do
      yield @rest_client.list_timeline(list.id, count: 200).map { |tweet| Status.new(tweet) }
    end
  end

  def favorite(status)
    return false unless status.is_a? Status

    Thread.new do
      @rest_client.favorite(status.id)
      status.favorite!
      yield status if block_given?
    end

    self
  end

  def unfavorite(status)
    fail ArgumentError, 'argument must be an instance of Status class' unless status.is_a? Status

    Thread.new do
      @rest_client.unfavorite(status.id)
      status.unfavorite!
      yield status if block_given?
    end
  end

  def retweet(status)
    return false unless status.is_a? Status

    Thread.new do
      begin
        @rest_client.retweet!(status.id)
        status.retweet!
        yield status if block_given?
      rescue Twitter::Error::AlreadyRetweeted, Twitter::Error::NotFound, Twitter::Error::Forbidden
        Notifier.instance.show_error 'Retweet attempt failed'
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

  def self.create(user_id, screen_name, token, secret)
    client = new(user_id, screen_name, token, secret)
    ClientManager.instance.push(client)
    client
  end

  private

  def on(event, &block)
    @callbacks[event] ||= []
    @callbacks[event] << block
    self
  end

  def invoke_callbacks(event, data = nil)
    return if @callbacks[event].nil?

    @callbacks[event].each do |callback|
      callback.call(data)
    end
    self
  end
end
