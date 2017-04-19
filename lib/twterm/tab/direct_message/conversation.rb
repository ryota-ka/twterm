require 'twterm/direct_message_composer'
require 'twterm/event/direct_message/fetched'
require 'twterm/subscriber'
require 'twterm/tab/base'
require 'twterm/tab/loadable'
require 'twterm/tab/searchable'

module Twterm
  module Tab
    module DirectMessage
      class Conversation < Base
        include Searchable
        include Subscriber
        include Loadable

        def drawable_item_count
          messages.drop(scroller.offset).lazy
            .map { |m| m.text.split_by_width(window.maxx - 4).count + 2 }
            .scan(0, :+)
            .each_cons(2)
            .select { |_, l| l < window.maxy }
            .count
        end

        def image
          return Image.string(initially_loaded? ? 'No results found' : 'Loading...') if items.empty?

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

            cursor = Image.cursor(m.height, scroller.current_index?(i))

            cursor - Image.whitespace - m
          end
            .intersperse(Image.blank_line)
            .reduce(Image.empty, :|)
        end

        def initialize(conversation)
          super()

          @conversation = conversation

          subscribe(Event::DirectMessage::Fetched) { initially_loaded! }
        end

        def items
          messages
        end

        def respond_to_key(key)
          return true if scroller.respond_to_key(key)

          k = KeyMapper.instance

          case key
          when k[:status, :compose], k[:status, :reply]
            DirectMessageComposer.instance.compose(conversation.collocutor)
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
