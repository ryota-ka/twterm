require 'twterm/event/notification/abstract_notification'

module Twterm
  module Event
    module Notification
      class Follow < AbstractNotification
        # @param [Twterm::User] user
        def initialize(user)
          @user = user
        end

        # @return [String] notification body
        def body
          user.description
        end

        # @return [String] notification title
        def title
          "@#{user.screen_name} has followed you"
        end

        # @return [String] notification url
        def url
          user.url
        end

        private

        attr_reader :user
      end
    end
  end
end
