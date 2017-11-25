require 'shellwords'

require 'twterm/notification_backend/abstract_notification_backend'

module Twterm
  module NotificationBackend
    class TmuxBackend < AbstractNotificationBackend
      # @param [Twterm::Event::Notification::AbstractNotification] notification notification to display in tmux status line
      # @return [void]
      def notify(notification)
        `tmux set-option display-time 3000`
        `tmux set-option message-style fg=black,bg=green`
        `tmux display #{Shellwords.escape(" [twterm] #{notification.fallback.gsub("\n", ' ')}")}`
      end
    end
  end
end
