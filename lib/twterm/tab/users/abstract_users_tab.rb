require 'concurrent'

require 'twterm/event/user_garbage_collected'
require 'twterm/image_builder/user_name_image_builder'
require 'twterm/tab/abstract_tab'
require 'twterm/tab/loadable'

module Twterm
  module Tab
    module Users
      class AbstractUsersTab < AbstractTab
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
          return Image.string(initially_loaded? ? 'No result found' : 'Loading...') if items.empty?

          drawable_items.map.with_index(0) do |user, i|
            cursor = Image.cursor(2, scroller.current_index?(i))

            header = [
              ImageBuilder::UserNameImageBuilder.new(user).build,
              (Image.string('protected').brackets.color(:yellow) if user.protected?),
              (Image.string('verified').brackets.color(:cyan) if user.verified?),
            ].compact.intersperse(Image.whitespace).reduce(Image.empty, :-)

            bio_chunks = user.description.gsub(/[\n\r]/, ' ').split_by_width(window.maxx - 10)
            cursor - Image.whitespace - (header | Image.string("#{bio_chunks[0]}#{'...' unless bio_chunks[1].nil?}"))
          end
            .intersperse(Image.blank_line)
            .reduce(Image.empty, :|)
        end
      end
    end
  end
end
