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

        def close
          @instance_keeper.kill
          super
        end

        def fetch; end

        def initialize
          super()
          @user_ids = []

          @instance_keeper = Scheduler.new(300) { items.each(&:touch!) }
        end

        def items
          user_ids.map(&User.method(:find)).compact
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
          tab = Tab::UserTab.new(user.id)
          TabManager.instance.add_and_show(tab)
        end

        def image
          return Image.string(initially_loaded? ? 'No result found' : 'Loading...') if items.empty?

          drawable_items.map.with_index(0) do |user, i|
            cursor = Image.cursor(2, scroller.current_index?(i))

            header = [
              !Image.string(user.name).color(user.color),
              Image.string("@#{user.screen_name}"),
              (Image.string('protected').brackets if user.protected?),
              (Image.string('verified').brackets if user.verified?),
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
