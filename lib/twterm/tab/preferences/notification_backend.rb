require 'twterm/image'
require 'twterm/preferences'
require 'twterm/publisher'
require 'twterm/tab/base'
require 'twterm/tab/scrollable'

module Twterm
  module Tab
    module Preferences
      class Text < Tab::Base
        include Scrollable
        include Publisher

        def drawable_item_count
          (window.maxy - 1) / 2
        end

        def image
          drawable_items.map.with_index do |item, i|
            curr = scroller.current_index?(i)
            cursor = image_factory.cursor(1, curr)
            desc, cond, =
              case item
              when :ambiguous_width
                [
                  'Treat ambiguous-width characters as double-width',
                  app.preferences[:text, :ambiguous_width] == 2,
                ]
              end
            checkbox = image_factory.checkbox(cond)

              cursor - image_factory.whitespace - checkbox - image_factory.whitespace - image_factory.string(desc).bold(curr)
          end
            .intersperse(image_factory.blank_line)
            .reduce(image_factory.empty) { |acc, x| acc | x }
        end

        def items
          [
            :ambiguous_width,
          ]
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
          'Text preferences'
        end

        private

        def perform_selected_action
          item = scroller.current_item

          case item
          when :ambiguous_width
            app.preferences[:text, :ambiguous_width] = 3 - app.preferences[:text, :ambiguous_width]
          end

          render
        end
      end
    end
  end
end
