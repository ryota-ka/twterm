require 'twterm/event/message/error'
require 'twterm/event/message/info'
require 'twterm/event/notification/direct_message'
require 'twterm/event/notification/favorite'
require 'twterm/event/notification/follow'
require 'twterm/event/notification/list_member_added'
require 'twterm/event/notification/mention'
require 'twterm/event/notification/quote'
require 'twterm/event/notification/retweet'
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
          publish(Event::Message::Info.new('Trying to connect to Twitter...'))
          streaming_client.user do |event|
            keep_alive!

            case event
            when Twitter::Tweet
              status = status_repository.create(event)
              user = user_repository.create(event.user)

              if status.text.include?('@%s' % screen_name)
                publish(Event::Status::Mention.new(status))

                notification = Event::Notification::Mention.new(status, user)
                publish(notification)
              end

              if status.retweet? && event.retweeted_status.user.id == user_id
                retweeted_status = status_repository.create(event.retweeted_status)
                notification = Event::Notification::Retweet.new(retweeted_status, user)
                publish(notification)
              end
            when Twitter::Streaming::Event
              case event.name
              when :favorite
                next if event.source.id == user_id
                user = user_repository.create(event.source)
                status = status_repository.create(event.target_object)
                notification = Event::Notification::Like.new(status, user)
                publish(notification)
              when :follow
                next if event.source.id == user_id

                user = user_repository.create(event.source)
                notification = Event::Notification::Follow.new(user)
                publish(notification)
              when :list_member_added
                next if event.source.id == user_id

                list = list_repository.create(event.target_object)
                notification = Event::Notification::ListMemberAdded.new(list)
                publish(notification)
              when :quoted_tweet
                next if event.source.id == user_id

                status = status_repository.create(event.target_object)
                user = user_repository.create(event.source)
                notification = Event::Notification::Quote.new(status, user)
                publish(notification)
              end
            when Twitter::DirectMessage
              next if event.sender.id == user_id

              user = user_repository.create(event.sender)
              message = DirectMessage.new(event)
              notification = Event::Notification::DirectMessage.new(message, user)
              publish(notification)
            when Twitter::Streaming::FriendList
              user_stream_connected!
            when Twitter::Streaming::DeletedTweet
              publish(Event::Status::Delete.new(event.id))
            end
          end
        rescue Twitter::Error::TooManyRequests
          publish(Event::Message::Error.new('Rate limit exceeded'))
          sleep 120
          retry
        rescue Errno::ENETUNREACH, Errno::ETIMEDOUT, Resolv::ResolvError
          publish(Event::Message::Error.new('Network is unavailable'))
          sleep 30
          retry
        rescue Twitter::Error => e
          publish(Event::Message::Error.new(e.message))
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
      publish(Event::Message::Info.new('Connection established')) unless user_stream_connected?
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
