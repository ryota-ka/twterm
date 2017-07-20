require 'twterm/event/favorite'
require 'twterm/event/follow'
require 'twterm/event/notification/error'
require 'twterm/event/notification/info'
require 'twterm/event/status/mention'
require 'twterm/event/status/timeline'
require 'twterm/publisher'

module Twterm
  module StreamingClient
    include Publisher

    CONSUMER_KEY = 'vLNSVFgXclBJQJRZ7VLMxL9lA'.freeze
    CONSUMER_SECRET = 'OFLKzrepRG2p1hq0nUB9j2S9ndFQoNTPheTpmOY0GYw55jGgS5'.freeze

    def connect_user_stream
      return if user_stream_connected?

      @streaming_thread = Thread.new do
        begin
          publish(Event::Notification::Info.new('Trying to connect to Twitter...'))
          streaming_client.user do |event|
            keep_alive!

            case event
            when Twitter::Tweet
              status = App.instance.status_repository.create(event)
              publish(Event::Status::Timeline.new(status))
              publish(Event::Status::Mention.new(status)) if status.text.include?('@%s' % screen_name)
            when Twitter::Streaming::Event
              case event.name
              when :favorite
                user = App.instance.user_repository.create(event.source)
                status = App.instance.status_repository.create(event.target_object)

                event = Event::Favorite.new(user, status, self)
                publish(event)
              when :follow
                source = App.instance.user_repository.create(event.source)
                target = App.instance.user_repository.create(event.target)

                event = Event::Follow.new(source, target, self)

                publish(event)
              end
            when Twitter::DirectMessage
            when Twitter::Streaming::FriendList
              user_stream_connected!
            when Twitter::Streaming::DeletedTweet
              publish(Event::Status::Delete.new(event.id))
            end
          end
        rescue Twitter::Error::TooManyRequests
          publish(Event::Notification::Error.new('Rate limit exceeded'))
          sleep 120
          retry
        rescue Errno::ENETUNREACH, Errno::ETIMEDOUT, Resolv::ResolvError
          publish(Event::Notification::Error.new('Network is unavailable'))
          sleep 30
          retry
        rescue Twitter::Error => e
          publish(Event::Notification::Error.new(e.message))
        end
      end
    end

    private

    def keep_alive!
      @keep_alive_timer.kill if @keep_alive_timer.is_a?(Thread)
      @keep_alive_timer = Thread.new do
        sleep(120)
        @user_stream_connected = false
        @streaming_thread.kill
        connect_user_stream
      end
    end

    def streaming_client
      @streaming_client ||= Twitter::Streaming::Client.new do |config|
        config.consumer_key       = CONSUMER_KEY
        config.consumer_secret    = CONSUMER_SECRET
        config.access_token        = @access_token
        config.access_token_secret = @access_token_secret
      end
    end

    def user_stream_connected?
      @user_stream_connected || false
    end

    def user_stream_connected!
      publish(Event::Notification::Info.new('Connection established')) unless user_stream_connected?
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
