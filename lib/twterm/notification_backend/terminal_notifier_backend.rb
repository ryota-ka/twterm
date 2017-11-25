require 'terminal-notifier'

require 'twterm/notification_backend/abstract_notification_backend'

module Twterm
  module NotificationBackend
    class TerminalNotifierBackend < AbstractNotificationBackend
      # @param [Twterm::Event::Notification::AbstractNotification] notification notification to display via terminal-notifier
      def notify(notification)
        opts = {
          title: 'twterm',
          subtitle: notification.title,
          group: Process.pid,
          sound: 'Purr',
        }

        opts[:open] = notification.url unless notification.url.nil?

        TerminalNotifier.notify(notification.body, opts)
      end
    end
  end
end
