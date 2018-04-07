require 'twterm/direct_message_composer'
require 'twterm/event/direct_message/fetched'
require 'twterm/image_builder/user_name_image_builder'
require 'twterm/string_width_measurer'
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
            .map { |m| split_string(m.text, window.maxx - 4).count + 2 }
            .scan(0, :+)
            .each_cons(2)
            .select { |_, l| l < window.maxy }
            .count
        end

        def image
          return image_factory.string(initially_loaded? ? 'No results found' : 'Loading...') if items.empty?

          scroller.drawable_items.map.with_index(0) do |message, i|
            sender = app.user_repository.find(message.sender_id)

            header = [
              ImageBuilder::UserNameImageBuilder.new(image_factory, sender).build,
              image_factory.string(message.date.to_s).brackets,
            ].intersperse(image_factory.whitespace).reduce(image_factory.empty, :-)

            body = split_string(message.text, window.maxx - 4)
              .map { |x| image_factory.string(x) }
              .reduce(image_factory.empty, :|)

            m = header | body

            cursor = image_factory.cursor(m.height, scroller.current_index?(i))

            cursor - image_factory.whitespace - m
          end
            .intersperse(image_factory.blank_line)
            .reduce(image_factory.empty, :|)
        end

        def initialize(app, client, conversation)
          super(app, client)

          @conversation = conversation

          subscribe(Event::DirectMessage::Fetched) { initially_loaded! }
        end

        def items
          messages
        end

        def matches?(message, query)
          sender = app.user_repository.find(message.sender_id)

          [
            message.text,
            sender.screen_name,
            sender.name
          ].any? { |x| x.downcase.include?(query.downcase) }
        end

        def respond_to_key(key)
          return true if scroller.respond_to_key(key)

          k = KeyMapper.instance

          case key
          when k[:status, :compose], k[:status, :reply]
            collocutor = app.user_repository.find(conversation.collocutor_id)
            app.direct_message_composer.compose(collocutor)
          else
            return false
          end

          true
        end

        def title
          collocutor = app.user_repository.find(conversation.collocutor_id)
          '@%s messages' % collocutor.screen_name
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
