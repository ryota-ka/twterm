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
            .each_cons(2)
            .select { |_, l| l < window.maxy }
            .count
        end

        def image
          scroller.drawable_items.map.with_index(0) do |message, i|
            header = [
              !Image.string(message.sender.name).color(message.sender.color),
              Image.string("@#{message.sender.screen_name}").parens,
              Image.string(message.date.to_s).brackets,
            ].intersperse(Image.whitespace).reduce(Image.empty, :-)

            body = message.text.split_by_width(window.maxx - 4)
              .map { |x| Image.string(x) }
              .reduce(Image.empty, :|)

            m = header | body

            cursor = Image.cursor(m.height, scroller.current_item?(i))

            cursor - Image.whitespace - m
          end
            .intersperse(Image.blank_line)
            .reduce(Image.empty, :|)
        end

        def initialize(conversation)
          super()

          @conversation = conversation

          subscribe(Event::DirectMessage::Fetched) { render }
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

          k = KeyMapper.instance

          case key
          when k[:tab, :filter]
            filter
          when k[:direct_message, :compose], k[:direct_message, :reply]
            DirectMessageComposer.instance.compose(conversation.collocutor)
          when k[:tab, :reset_filter]
            reset_filter
          else
            return false
          end

          true
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
