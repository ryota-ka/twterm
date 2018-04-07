require 'concurrent'

require 'twterm/event/user_garbage_collected'
require 'twterm/image_builder/user_name_image_builder'
require 'twterm/tab/base'
require 'twterm/tab/loadable'

module Twterm
  module Tab
    module Users
      class Base < Tab::Base
        include Loadable
        include Searchable

        attr_reader :user_ids

        def drawable_item_count
          (window.maxy - 6).div(3)
        end

        def fetch; end

        def initialize(app, client)
          super(app, client)
          @user_ids = Concurrent::Array.new

          subscribe(Event::UserGarbageCollected) { |id| @user_ids.delete(id) }
        end

        def items
          user_ids.map { |id| app.user_repository.find(id) }.compact
        end

        def matches?(user, query)
          [
            user.name,
            user.screen_name,
            user.description
          ].compact.any? { |x| x.downcase.include?(query.downcase) }
        end

        def respond_to_key(key)
          return true if scroller.respond_to_key(key)

          k = KeyMapper.instance

          case key
          when 10
            show_user
          when k[:tab, :reload]
            fetch
          else
            return false
          end

          true
        end

        def title
          'User list'
        end

        private

        def show_user
          user = current_item
          tab = Tab::UserTab.new(app, client, user.id)
          app.tab_manager.add_and_show(tab)
        end

        def image
          return image_factory.string(initially_loaded? ? 'No result found' : 'Loading...') if items.empty?

          drawable_items.map.with_index(0) do |user, i|
            cursor = image_factory.cursor(2, scroller.current_index?(i))

            header = [
              ImageBuilder::UserNameImageBuilder.new(image_factory, user).build,
              (image_factory.string('protected').brackets.color(:yellow) if user.protected?),
              (image_factory.string('verified').brackets.color(:cyan) if user.verified?),
            ].compact.intersperse(image_factory.whitespace).reduce(image_factory.empty, :-)

            bio_chunks = split_string(user.description.gsub(/[\n\r]/, ' '), window.maxx - 10)
            cursor - image_factory.whitespace - (header | image_factory.string("#{bio_chunks[0]}#{'...' unless bio_chunks[1].nil?}"))
          end
            .intersperse(image_factory.blank_line)
            .reduce(image_factory.empty, :|)
        end
      end
    end
  end
end
