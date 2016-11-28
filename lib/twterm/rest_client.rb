require 'twterm/direct_message'
require 'twterm/direct_message_manager'
require 'twterm/publisher'
require 'twterm/event/notification'

module Twterm
  module RESTClient
    include Publisher

    CONSUMER_KEY = 'vLNSVFgXclBJQJRZ7VLMxL9lA'.freeze
    CONSUMER_SECRET = 'OFLKzrepRG2p1hq0nUB9j2S9ndFQoNTPheTpmOY0GYw55jGgS5'.freeze

    def block(*user_ids)
      send_request do
        rest_client.block(*user_ids)
      end.then do |users|
        users.each do |user|
          Friendship.block(self.user_id, user.id)
        end
      end
    end

    def create_direct_message(recipient, text)
      send_request do
        rest_client.create_direct_message(recipient.id, text)
      end.then do |message|
        msg = DirectMessage.new(message)
        direct_message_manager.add(msg.recipient, msg)
        publish(Event::DirectMessage::Fetched.new)
        publish(Event::Notification.new(:message, 'Your message to @%s has been sent' % msg.recipient.screen_name))
      end
    end

    def direct_message_conversations
      direct_message_manager.conversations
    end

    def direct_messages_received
      send_request do
        rest_client.direct_messages(count: 200).map(&DirectMessage.method(:new))
      end
    end

    def direct_messages_sent
      send_request do
        rest_client.direct_messages_sent(count: 200).map(&DirectMessage.method(:new))
      end
    end

    def destroy_status(status)
      send_request_without_catch do
        rest_client.destroy_status(status.id)
        publish(Event::Status::Delete.new(status.id))
        publish(Event::Notification.new(:message, 'Your tweet has been deleted'))
      end.catch do |reason|
        case reason
        when Twitter::Error::NotFound, Twitter::Error::Forbidden
          publish(Event::Notification.new(:error, 'You cannot destroy that status'))
        else
          raise reason
        end
      end.catch(&show_error)
    end

    def favorite(status)
      return false unless status.is_a? Status

      send_request do
        rest_client.favorite(status.id)
      end.then do
        status.favorite!
        publish(Event::Notification.new(:message, 'Successfully liked: @%s "%s"' % [
          status.user.screen_name, status.text
        ]))
      end
    end

    def favorites(user_id = nil)
      user_id ||= self.user_id

      send_request do
        rest_client.favorites(user_id, count: 200)
      end.then do |tweets|
        tweets.map(&Status.method(:new))
      end
    end

    def fetch_muted_users
      send_request do
        @muted_user_ids = rest_client.muted_ids.to_a
      end
    end

    def follow(*user_ids)
      send_request do
        rest_client.follow(*user_ids)
      end.then do |users|
        users.each do |user|
          if user.protected?
            Friendship.following_requested(self.user_id, user.id)
          else
            Friendship.follow(self.user_id, user.id)
          end
        end
      end
    end

    def followers(user_id = nil)
      user_id ||= self.user_id

      m = Mutex.new

      send_request do
        rest_client.follower_ids(user_id).each_slice(100) do |user_ids|
          m.synchronize do
            users = rest_client.users(*user_ids).map(& -> u { User.new(u) })
            users.each do |user|
              Friendship.follow(user.id, self.user_id)
            end if user_id == self.user_id
            yield users
          end
        end
      end
    end

    def friends(user_id = nil)
      user_id ||= self.user_id

      m = Mutex.new

      send_request do
        rest_client.friend_ids(user_id).each_slice(100) do |user_ids|
          m.synchronize do
            yield rest_client.users(*user_ids).map(& -> u { User.new(u) })
          end
        end
      end
    end

    def home_timeline
      send_request do
        rest_client.home_timeline(count: 200)
      end.then do |statuses|
        statuses
        .select(&@mute_filter)
        .map(&Status.method(:new))
      end
    end

    def list(list_id)
      send_request do
        rest_client.list(list_id)
      end.then do |list|
        List.new(list)
      end
    end

    def list_timeline(list)
      fail ArgumentError,
        'argument must be an instance of List class' unless list.is_a? List
      send_request do
        rest_client.list_timeline(list.id, count: 200)
      end.then do |statuses|
        statuses
        .select(&@mute_filter)
        .map(&Status.method(:new))
      end
    end

    def lists
      send_request do
        rest_client.lists
      end.then do |lists|
        lists.map { |list| List.new(list) }
      end
    end

    def lookup_friendships
      user_ids = User.ids.reject { |id| Friendship.already_looked_up?(id) }
      send_request_without_catch do
        user_ids.each_slice(100) do |chunked_user_ids|
          friendships = rest_client.friendships(*chunked_user_ids)
          friendships.each do |friendship|
            id = friendship.id
            client_id = user_id

            conn = friendship.connections
            conn.include?('blocking') ? Friendship.block(client_id, id) : Friendship.unblock(client_id, id)
            conn.include?('following') ? Friendship.follow(client_id, id) : Friendship.unfollow(client_id, id)
            conn.include?('following_requested') ? Friendship.following_requested(client_id, id) : Friendship.following_not_requested(client_id, id)
            conn.include?('followed_by') ? Friendship.follow(id, client_id) : Friendship.unfollow(id, client_id)
            conn.include?('muting') ? Friendship.mute(client_id, id) : Friendship.unmute(client_id, id)

            Friendship.looked_up!(id)
          end
        end
      end.catch do |e|
        case e
        when Twitter::Error::TooManyRequests
          # do nothing
        else
          raise e
        end
      end.catch(&show_error)
    end

    def mentions
      send_request do
        rest_client.mentions(count: 200)
      end.then do |statuses|
        statuses
        .select(&@mute_filter)
        .map(&Status.method(:new))
      end
    end

    def mute(user_ids)
      send_request do
        rest_client.mute(*user_ids)
      end.then do |users|
        users.each do |user|
          Friendship.mute(self.user_id, user.id)
        end
      end
    end

    def post(text, in_reply_to = nil)
      send_request do
        if in_reply_to.is_a? Status
          text = "@#{in_reply_to.user.screen_name} #{text}"
          rest_client.update(text, in_reply_to_status_id: in_reply_to.id)
        else
          rest_client.update(text)
        end
        publish(Event::Notification.new(:message, 'Your tweet has been posted'))
      end
    end

    def retweet(status)
      fail ArgumentError,
        'argument must be an instance of Status class' unless status.is_a? Status

      send_request_without_catch do
        rest_client.retweet!(status.id)
      end.then do
        status.retweet!
        publish(Event::Notification.new(:message, 'Successfully retweeted: @%s "%s"' % [
          status.user.screen_name, status.text
        ]))
      end.catch do |reason|
        message =
          case reason
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
        publish(Event::Notification.new(:error, "Retweet attempt failed: #{message}"))
      end.catch(&show_error)
    end

    def saved_search
      send_request do
        rest_client.saved_searches
      end
    end

    def search(query)
      send_request do
        rest_client.search(query, count: 100).attrs[:statuses]
      end.then do |statuses|
        statuses
        .map(&Twitter::Tweet.method(:new))
        .map(&Status.method(:new))
      end
    end

    def show_status(status_id)
      send_request do
        rest_client.status(status_id)
      end.then do |status|
        Status.new(status)
      end
    end

    def show_user(query)
      send_request_without_catch do
        rest_client.user(query)
      end.catch do |reason|
        case reason
        when Twitter::Error::NotFound
          nil
        else
          raise reason
        end
      end.catch(&show_error).then do |user|
        user.nil? ? nil : User.new(user)
      end
    end

    def unblock(*user_ids)
      send_request do
        rest_client.unblock(*user_ids)
      end.then do |users|
        users.each do |user|
          Friendship.unblock(self.user_id, user.id)
        end
      end
    end

    def unfavorite(status)
      fail ArgumentError,
        'argument must be an instance of Status class' unless status.is_a? Status

      send_request do
        rest_client.unfavorite(status.id)
      end.then do
        status.unfavorite!
        publish(Event::Notification.new(:message, 'Successfully unliked: @%s "%s"' % [
          status.user.screen_name, status.text
        ]))
      end
    end

    def unfollow(*user_ids)
      send_request do
        rest_client.unfollow(*user_ids)
      end.then do |users|
        users.each do |user|
          Friendship.unfollow(self.user_id, user.id)
        end
      end
    end

    def unmute(user_ids)
      send_request do
        rest_client.unmute(*user_ids)
      end.then do |users|
        users.each do |user|
          Friendship.unmute(self.user_id, user.id)
        end
      end
    end

    def user_timeline(user_id)
      send_request do
        rest_client.user_timeline(user_id, count: 200)
      end.then do |statuses|
        statuses
        .select(&@mute_filter)
        .map(&Status.method(:new))
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

    def send_request(&block)
      send_request_without_catch(&block).catch(&show_error)
    end

    def send_request_without_catch(&block)
      Promise.new do |resolve, reject|
        begin
          resolve.(block.call)
        rescue Twitter::Error => reason
          reject.(reason)
        end
      end
    end

    private

    def direct_message_manager
      @direct_message_manager ||= DirectMessageManager.new(self)
    end

    def show_error
      proc do |e|
        case e
        when Twitter::Error
          publish(Event::Notification.new(:error, "Failed to send request: #{e.message}"))
        else
          raise e
        end
      end
    end
  end
end
