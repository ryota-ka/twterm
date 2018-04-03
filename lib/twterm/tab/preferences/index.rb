require 'twterm/image'
require 'twterm/tab/preferences/notification_backend'
require 'twterm/tab/preferences/photo_viewer_backend'
require 'twterm/preferences'
require 'twterm/publisher'
require 'twterm/tab/abstract_tab'
require 'twterm/tab/scrollable'

module Twterm
  module Tab
    module Preferences
      class Index < AbstractTab
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
            cursor = Image.cursor(1, curr)
            desc =
              case item
              when :notification_backend
                'Notification backend preferences'
              when :photo_viewer_backend
                'Photo viewer backend preferences'
              end

              cursor - Image.whitespace - Image.string(desc).bold(curr)
          end
            .intersperse(Image.blank_line)
            .reduce(Image.empty) { |acc, x| acc | x }
        end

        def items
          [
            :notification_backend,
            :photo_viewer_backend,
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
            when :photo_viewer_backend
              Tab::Preferences::PhotoViewerBackend.new(app, client)
            end

          app.tab_manager.add_and_show(tab)
        end
      end
    end
  end
end
