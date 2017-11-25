require 'curses'

require 'twterm/event/message/info'
require 'twterm/notification_backend/abstract_notification_backend'
require 'twterm/publisher'

module Twterm
  module NotificationBackend
    class InlineBackend < AbstractNotificationBackend
      include Publisher

      # @param [Twterm::Event::Notification::AbstractNotification] notification
      # @return [void]
      def notify(notification)
        message = Event::Message::Info.new(notification.fallback)
        publish(message)
      end
    end
  end
end
