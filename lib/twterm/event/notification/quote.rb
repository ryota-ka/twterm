require 'twterm/event/notification/abstract_notification'

module Twterm
  module Event
    module Notification
      class Quote < AbstractNotification
        # @param [Twterm::Status] status
        # @param [Twterm::User] user
        def initialize(status, user)
          @status = status
          @user = user
        end

        # @return [String] notification body
        def body
          status.text
        end

        # @return [String] notification title
        def title
          "@#{user.screen_name} has quoted your tweet"
        end

        # @return [String] notification url
        def url
          status.url
        end

        private

        attr_reader :status, :user
      end
    end
  end
end
