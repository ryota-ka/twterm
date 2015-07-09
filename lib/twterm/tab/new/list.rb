module Twterm
  module Tab
    module New
      class List
        include Base
        include Scrollable

        @@lists = nil

        def ==(other)
          other.is_a?(self.class)
        end

        def drawable_item_count
          (window.maxy - 2).div(3)
        end

        def initialize
          super

          @title = 'New tab'
          refresh
        end

        def items
          @@lists
        end

        def respond_to_key(key)
          case key
          when ?g
            scroller.move_to_top
          when ?G
            scroller.move_to_bottom
          when ?j, 14, Curses::Key::DOWN
            scroller.move_down
          when 10
            return true if current_list.nil?
            list_tab = Tab::ListTab.new(current_list.id)
            TabManager.instance.switch(list_tab)
          when ?k, 16, Curses::Key::UP
            scroller.move_up
          else
            return false
          end
          true
        end

        def total_item_count
          @@lists.nil? ? 0 : @@lists.count
        end

        private

        def current_list
          @@lists.nil? ? nil : @@lists[scroller.index]
        end

        def show_lists
          return if @@lists.nil?

          index, offset = scroller.index, scroller.offset

          drawable_items.each.with_index(0) do |list, i|
            window.with_color(:black, :magenta) do
              window.setpos(i * 3 + 5, 4)
              window.addstr(' ')
              window.setpos(i * 3 + 6, 4)
              window.addstr(' ')
            end if scroller.current_item?(i)

            window.setpos(i * 3 + 5, 6)
            window.addstr("#{list.full_name} (#{list.member_count} members / #{list.subscriber_count} subscribers)")
            window.setpos(i * 3 + 6, 8)
            window.addstr(list.description)
          end
        end

        def update
          window.setpos(2, 3)
          window.bold { window.addstr('Open list tab') }

          Thread.new do
            Notifier.instance.show_message('Loading lists ...')
            Client.current.lists do |lists|
              @@lists = lists.sort_by(&:full_name)
              show_lists
              window.refresh if TabManager.instance.current_tab == self
            end
          end if @@lists.nil?

          show_lists
        end
      end
    end
  end
end
