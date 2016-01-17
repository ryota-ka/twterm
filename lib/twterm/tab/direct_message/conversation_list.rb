require 'twterm/direct_message_composer'
require 'twterm/event/direct_message/fetched'
require 'twterm/subscriber'
require 'twterm/tab/direct_message/conversation'

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

        def ==(other)
          other.is_a?(self.class)
        end

        def items
          if filter_query.empty?
            Client.current.direct_message_conversations
          else
            Client.current.direct_message_conversations.select { |c| c.matches?(filter_query) }
          end
        end

        def respond_to_key(key)
          return true if scroller.respond_to_key(key)

          case key
          when 10
            open_conversation
          when ?n, ?r
            conversation = current_item
            DirectMessageComposer.instance.compose(conversation.collocutor)
          when ?/
            filter
          when ?q
            reset_filter
          else
            return false
          end

          true
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

        private

        def open_conversation
          conversation = scroller.current_item

          tab = Tab::DirectMessage::Conversation.new(conversation)
          TabManager.instance.add_and_show(tab)
        end
      end
    end
  end
end
