module Twterm
  module Tab
    module Users
      module Base
        include Tab::Base
        include FilterableList
        include Scrollable

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
          users = user_ids.map { |id| User.find(id) }.reject(&:nil?)
          filter_query.empty? ? users : users.select { |user| user.matches?(filter_query) }
        end

        def respond_to_key(key)
          return true if scroller.respond_to_key(key)

          case key
          when 10, ?U
            show_user
          when 18
            fetch
          when ?q
            reset_filter
          when ?/
            filter
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

        def update
          window.setpos(2, 3)
          window.bold { window.addstr(title) }

          drawable_items.each.with_index(0) do |user, i|
            window.with_color(:black, :magenta) do
              window.setpos(i * 3 + 5, 3)
              window.addch(' ')
              window.setpos(i * 3 + 6, 3)
              window.addch(' ')
            end if scroller.current_item?(i)

            window.setpos(i * 3 + 5, 5)
            window.bold { window.with_color(user.color) { window.addstr(user.name) } }
            window.addstr(" (@#{user.screen_name})")
            window.with_color(:yellow) { window.addstr(' [protected]') } if user.protected?
            window.with_color(:cyan) { window.addstr(' [verified]') } if user.verified?
            window.setpos(i * 3 + 6, 7)
            bio_chunks = user.description.gsub(/[\n\r]/, ' ').split_by_width(window.maxx - 10)
            window.addstr(bio_chunks[0] + (bio_chunks[1].nil? ? '' : '...'))
          end
        end
      end
    end
  end
end
