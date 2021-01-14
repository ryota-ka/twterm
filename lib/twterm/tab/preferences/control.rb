require 'twterm/image'
require 'twterm/preferences'
require 'twterm/publisher'
require 'twterm/tab/abstract_tab'
require 'twterm/tab/scrollable'

module Twterm
  module Tab
    module Preferences
      class Control < AbstractTab
        include Scrollable
        include Publisher

        def drawable_item_count
          1
        end

        def image
          drawable_items.map.with_index do |item, i|
            curr = scroller.current_index?(i)
            cursor = Image.cursor(2, curr)
            options = Image.toggle_switch(['traditional', 'natural'], app.preferences[:control, item])
            desc =
              case item
              when :scroll_direction
                header = Image.string('Scroll direction')
                body = Image.string('  ') - options
                cursor - Image.whitespace - (header | body)
              end
          end
            .intersperse(Image.blank_line)
            .reduce(Image.empty) { |acc, x| acc | x }
        end

        def items
          [
            :scroll_direction,
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
          'Control preferences'
        end

        private

        def perform_selected_action
          item = scroller.current_item

          case item
          when :scroll_direction
            app.preferences[:control, :scroll_direction] =
              case app.preferences[:control, :scroll_direction]
              when 'natural'
                'traditional'
              when 'traditional'
                'natural'
              end
          end

          render
        end
      end
    end
  end
end
