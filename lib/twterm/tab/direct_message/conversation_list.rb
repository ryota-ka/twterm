require 'twterm/event/direct_message/fetched'
require 'twterm/subscriber'

module Twterm
  module Tab
    module DirectMessage
      class ConversationList
        include Base
        include FilterableList
        include Scrollable
        include Subscriber

        def drawable_item_count
          window.maxy.-(2).div(3)
        end

        def initialize
          super

          subscribe(Event::DirectMessage::Fetched) { refresh }
        end

        def items
          Client.current.direct_message_conversations
        end

        def respond_to_key(key)
          return true if scroller.respond_to_key(key)

          false
        end

        def update
          scroller.drawable_items.each.with_index(0) do |conversation, i|
            line = 3 * i

            window.with_color(:black, :magenta) do
              2.times do |j|
                window.setpos(line + j, 0)
                window.addch(' ')
              end
            end if scroller.current_item?(i)

            window.setpos(line, 2)

            window.bold do
              window.with_color(conversation.collocutor.color) do
                window.addstr(conversation.collocutor.name)
              end
            end

            window.addstr(' (@%s)' % conversation.collocutor.screen_name)
            window.addstr(' [%s]' % conversation.updated_at)

            window.setpos(line + 1, 2)
            window.addstr(conversation.preview.split_by_width(window.maxx - 4).first)
          end
        end

        def title
          'Direct Messages'
        end
      end
    end
  end
end
