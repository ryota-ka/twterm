require 'twterm/event/notification/abstract_notification'

module Twterm
  module Event
    module Notification
      class DirectMessage < AbstractNotification
        # @param [Twterm::DirectMessage] message
        # @param [Twterm::User] user
        def initialize(message, user)
          @message = message
          @user = user
        end

        # @return [String] notification body
        def body
          message.text
        end

        # @return [String] notification title
        def title
          "@#{user.screen_name} has sent you a message"
        end

        private

        attr_reader :message, :user
      end
    end
  end
end
