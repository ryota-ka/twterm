require 'twterm/rest_client'
require 'twterm/streaming_client'

module Twterm
  class Client
    include RESTClient
    include StreamingClient

    attr_reader :user_id, :screen_name

    @@instances = []

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

      initialize_user_stream

      @@instances << self
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

    def show_error
      proc do |e|
        case e
        when Twitter::Error
          Notifier.instance.show_error "Failed to send request: #{e.message}"
        else
          raise e
        end
      end.freeze
    end
  end
end
