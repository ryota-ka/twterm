require 'twterm/image'
require 'twterm/tab/preferences/notification_backend'
require 'twterm/tab/preferences/text'
require 'twterm/preferences'
require 'twterm/publisher'
require 'twterm/tab/base'
require 'twterm/tab/scrollable'

module Twterm
  module Tab
    module Preferences
      class Index < Tab::Base
        include Scrollable

        def initialize(app, client)
          super(app, client)
        end

        def drawable_item_count
          (window.maxy - 1) / 2
        end

        def image
          drawable_items.map.with_index do |item, i|
            curr = scroller.current_index?(i)
            cursor = image_factory.cursor(1, curr)
            desc =
              case item
              when :notification_backend
                'Notification backend preferences'
              when :text
                'Text'
              end

              cursor - image_factory.whitespace - image_factory.string(desc).bold(curr)
          end
            .intersperse(image_factory.blank_line)
            .reduce(image_factory.empty) { |acc, x| acc | x }
        end

        def items
          [
            :notification_backend,
            :text
          ]
        end

        def respond_to_key(key)
          return true if scroller.respond_to_key(key)

          case key
          when 10
            open
          else
            return false
          end

          true
        end

        def title
          'Preferences'
        end

        private

        def open
          tab =
            case scroller.current_item
            when :notification_backend
              Tab::Preferences::NotificationBackend.new(app, client)
            when :text
              Tab::Preferences::Text.new(app, client)
            end

          app.tab_manager.add_and_show(tab)
        end
      end
    end
  end
end
