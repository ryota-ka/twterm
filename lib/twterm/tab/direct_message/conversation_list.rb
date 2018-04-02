require 'twterm/direct_message_composer'
require 'twterm/event/direct_message/fetched'
require 'twterm/image_builder/user_name_image_builder'
require 'twterm/subscriber'
require 'twterm/tab/base'
require 'twterm/tab/loadable'
require 'twterm/tab/direct_message/conversation'

module Twterm
  module Tab
    module DirectMessage
      class ConversationList < Base
        include Loadable
        include Searchable
        include Subscriber

        def drawable_item_count
          window.maxy.-(2).div(3)
        end

        def image
          return Image.string(initially_loaded? ? 'No results found' : 'Loading...') if items.empty?

          scroller.drawable_items.map.with_index(0) do |conversation, i|
            cursor = Image.cursor(2, scroller.current_index?(i))

            collocutor = app.user_repository.find(conversation.collocutor_id)

            header = [
              ImageBuilder::UserNameImageBuilder.new(collocutor).build,
              Image.string(conversation.updated_at.to_s).brackets,
            ].intersperse(Image.whitespace).reduce(Image.empty, :-)

            body = Image.string(conversation.preview.split_by_width(window.maxx - 4).first)

            cursor - Image.whitespace - (header | body)
          end
            .intersperse(Image.blank_line)
            .reduce(Image.empty, :|)
        end

        def initialize(app, client)
          super(app, client)

          subscribe(Event::DirectMessage::Fetched) { initially_loaded! }
        end

        def ==(other)
          other.is_a?(self.class)
        end

        def items
          client.direct_message_conversations
        end

        def matches?(conversation, query)
          collocutor = app.user_repository.find(conversation.collocutor_id)

          [
            collocutor.name,
            collocutor.screen_name,
            conversation.preview
          ].any? { |x| x.downcase.include?(query.downcase) }
        end

        def respond_to_key(key)
          return true if scroller.respond_to_key(key)

          k = KeyMapper.instance

          case key
          when 10
            open_conversation
          when k[:status, :compose], k[:status, :reply]
            conversation = current_item
            collocutor = app.user_repository.find(conversation.collocutor_id)
            app.direct_message_composer.compose(collocutor)
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

          tab = Tab::DirectMessage::Conversation.new(app, client, conversation)
          app.tab_manager.add_and_show(tab)
        end
      end
    end
  end
end
