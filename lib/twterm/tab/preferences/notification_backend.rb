require 'twterm/image'
require 'twterm/preferences'
require 'twterm/publisher'
require 'twterm/tab/base'
require 'twterm/tab/scrollable'

module Twterm
  module Tab
    module Preferences
      class NotificationBackend < Tab::Base
        include Scrollable
        include Publisher

        def drawable_item_count
          (window.maxy - 1) / 2
        end

        def image
          drawable_items.map.with_index do |item, i|
            cursor = Image.cursor(1, scroller.current_index?(i))
            checkbox = Image.checkbox(app.preferences[:notification_backend, item])
            desc =
              case item
              when :inline
                'Inline backend'
              when :tmux
                'Tmux backend'
              when :terminal_notifier
                'Terminal Notifier backend'
              end

              cursor - Image.whitespace - checkbox - Image.whitespace - Image.string(desc)
          end
            .intersperse(Image.blank_line)
            .reduce(Image.empty) { |acc, x| acc | x }
        end

        def items
          env = app.environment

          [
            :inline,
            (:tmux if env.with_tmux?),
            (:terminal_notifier if env.terminal_notifier_available?),
          ].compact
        end

        def respond_to_key(key)
          return true if scroller.respond_to_key(key)

          case key
          when 10
            perform_selected_action
          end

          false
        end

        def title
          'Notification backend preferences'
        end

        private

        def perform_selected_action
          item = scroller.current_item

          case item
          when :inline
            app.preferences[:notification_backend, :inline] =
              !app.preferences[:notification_backend, :inline]
          when :terminal_notifier
            app.preferences[:notification_backend, :terminal_notifier] =
              !app.preferences[:notification_backend, :terminal_notifier]
          when :tmux
            app.preferences[:notification_backend, :tmux] =
              !app.preferences[:notification_backend, :tmux]
          end

          render
        end
      end
    end
  end
end
