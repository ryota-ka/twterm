require 'twterm/direct_message_composer'
require 'twterm/event/direct_message/fetched'
require 'twterm/subscriber'
require 'twterm/tab/base'

module Twterm
  module Tab
    module DirectMessage
      class Conversation < Base
        include FilterableList
        include Scrollable
        include Subscriber

        def drawable_item_count
          messages.drop(scroller.offset).lazy
            .map { |m| m.text.split_by_width(window.maxx - 4).count + 2 }
            .scan(0, :+)
            .select { |l| l < window.maxy }
            .count
        end

        def initialize(conversation)
          super()

          @conversation = conversation

          subscribe(Event::DirectMessage::Fetched) { refresh }
        end

        def items
          if filter_query.empty?
            messages
          else
            messages.select { |m| m.matches?(filter_query) }
          end
        end

        def respond_to_key(key)
          return true if scroller.respond_to_key(key)

          case key
          when ?/
            filter
          when ?n, ?r
            DirectMessageComposer.instance.compose(conversation.collocutor)
          when ?q
            reset_filter
          else
            return false
          end

          true
        end

        def update
          line = 0

          scroller.drawable_items.each.with_index(0) do |message, i|
            formatted_lines = message.text.split_by_width(window.maxx - 4).count

            window.with_color(:black, :magenta) do
              formatted_lines.+(1).times do |j|
                window.setpos(line + j, 0)
                window.addch(' ')
              end
            end if scroller.current_item?(i)

            window.setpos(line, 2)

            window.bold do
              window.with_color(message.sender.color) do
                window.addstr(message.sender.name)
              end
            end

            window.addstr(' (@%s)' % message.sender.screen_name)
            window.addstr(' [%s]' % message.date)

            message.text.split_by_width(window.maxx - 4).each do |str|
              line += 1
              window.setpos(line, 2)
              window.addstr(str)
            end

            line += 2
          end
        end

        def title
          '@%s messages' % conversation.collocutor.screen_name
        end

        private

        attr_reader :conversation

        def messages
          @conversation.messages
        end
      end
    end
  end
end
