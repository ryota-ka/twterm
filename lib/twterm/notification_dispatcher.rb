require 'twterm/event/notification/abstract_notification'
require 'twterm/notification_backend/inline_backend'
require 'twterm/notification_backend/terminal_notifier_backend'
require 'twterm/notification_backend/tmux_backend'
require 'twterm/subscriber'

module Twterm
  class NotificationDispatcher
    include Subscriber

    # @param [Twterm::Preferences] preferences
    def initialize(preferences)
      @preferences = preferences

      @backends = {
        inline: NotificationBackend::InlineBackend.new,
        terminal_notifier: NotificationBackend::TerminalNotifierBackend.new,
        tmux: NotificationBackend::TmuxBackend.new,
      }

      subscribe(Event::Notification::AbstractNotification) { |n| dispatch(n) }
    end

    private

    attr_reader :backends, :preferences

    # @param [Twterm::Notification::AbstractNotification] notification notification to dispatch to backends
    # @return [void]
    def dispatch(notification)
      backends.keys.each do |key|
        backends[key].notify(notification) if preferences[:notification_backend, key]
      end
    end
  end
end
