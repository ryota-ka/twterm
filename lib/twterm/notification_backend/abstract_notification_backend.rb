module Twterm
  module NotificationBackend
    # @abstract
    class AbstractNotificationBackend
      # @abstract
      # @param [Twterm::Event::Notification::AbstractNotification] _notification a notification to show
      def notify(_notification)
        raise NotImplementedError, '`notify` method must be implemented'
      end

      private

      attr_reader :app
    end
  end
end
