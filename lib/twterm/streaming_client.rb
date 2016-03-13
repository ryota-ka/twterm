require 'twterm/event/favorite'
require 'twterm/event/notification'
require 'twterm/event/status/mention'
require 'twterm/event/status/timeline'
require 'twterm/publisher'

module Twterm
  module StreamingClient
    include Publisher

    CONSUMER_KEY = 'vLNSVFgXclBJQJRZ7VLMxL9lA'.freeze
    CONSUMER_SECRET = 'OFLKzrepRG2p1hq0nUB9j2S9ndFQoNTPheTpmOY0GYw55jGgS5'.freeze

    def connect_user_stream
      streaming_client.stop_stream

      @streaming_thread = Thread.new do
        begin
          publish(Event::Notification.new(:message, 'Trying to connect to Twitter...'))
          streaming_client.userstream
        rescue EventMachine::ConnectionError
          publish(Event::Notification.new(:error, 'Connection failed'))
          sleep 30
          retry
        end
      end
    end

    def initialize_user_stream
      return if user_stream_initialized?

      streaming_client.on_friends do
        user_stream_connected!
      end

      streaming_client.on_timeline_status do |tweet|
        status = Status.new(tweet)
        publish(Event::Status::Timeline.new(status))
        publish(Event::Status::Mention.new(status)) if status.text.include?('@%s' % screen_name)
      end

      streaming_client.on_delete do |status_id|
        publish(Event::StatusDeleted.new(status_id))
      end

      streaming_client.on_event(:favorite) do |event|
        user = User.new(Twitter::User.new(event[:source]))
        status = Status.new(Twitter::Status.new(event[:target_object]))

        event = Event::Favorite.new(user, status, self)
        publish(event)
      end

      streaming_client.on_event(:follow) do |event|
        source = User.new(Twitter::User.new(event[:source]))
        target = User.new(Twitter::User.new(event[:target]))

        event = Event::Follow.new(source, target, self)
        publish(:followed, event)
      end

      streaming_client.on_no_data_received do
        user_stream_disconnected!
        connect_user_stream
      end

      user_stream_initialized!
    end

    private

    def streaming_client
      @streaming_client ||= TweetStream::Client.new(
        consumer_key:       CONSUMER_KEY,
        consumer_secret:    CONSUMER_SECRET,
        oauth_token:        @access_token,
        oauth_token_secret: @access_token_secret,
        auth_method:        :oauth
      )
    end

    def user_stream_connected?
      @user_stream_connected || false
    end

    def user_stream_connected!
      publish(Event::Notification.new(:message, 'Connection established')) unless user_stream_connected?
      @user_stream_connected = true
    end

    def user_stream_disconnected!
      @user_stream_connected = false
    end

    def user_stream_initialized?
      @user_stream_initialized || false
    end

    def user_stream_initialized!
      @user_stream_initialized = true
    end
  end
end
