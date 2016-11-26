require 'twterm/direct_message_composer'
require 'twterm/event/direct_message/fetched'
require 'twterm/subscriber'
require 'twterm/tab/base'
require 'twterm/tab/direct_message/conversation'

module Twterm
  module Tab
    module DirectMessage
      class ConversationList < Base
        include Searchable
        include Subscriber

        def drawable_item_count
          window.maxy.-(2).div(3)
        end

        def image
          scroller.drawable_items.map.with_index(0) do |conversation, i|
            cursor = Image.cursor(2, scroller.current_index?(i))

            header = [
              !Image.string(conversation.collocutor.name).color(conversation.collocutor.color),
              Image.string("@#{conversation.collocutor.screen_name}").parens,
              Image.string(conversation.updated_at.to_s).brackets,
            ].intersperse(Image.whitespace).reduce(Image.empty, :-)

            body = Image.string(conversation.preview.split_by_width(window.maxx - 4).first)

            cursor - Image.whitespace - (header | body)
          end
            .intersperse(Image.blank_line)
            .reduce(Image.empty, :|)
        end

        def initialize
          super

          subscribe(Event::DirectMessage::Fetched) { render }
        end

        def ==(other)
          other.is_a?(self.class)
        end

        def items
          Client.current.direct_message_conversations
        end

        def respond_to_key(key)
          return true if scroller.respond_to_key(key)

          k = KeyMapper.instance

          case key
          when 10
            open_conversation
          when k[:direct_message, :compose], k[:direct_message, :reply]
            conversation = current_item
            DirectMessageComposer.instance.compose(conversation.collocutor)
          when k[:tab, :filter]
            filter
          else
            return false
          end

          true
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
