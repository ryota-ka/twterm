module Twterm
  module Tab
    module New
      class List
        include Base

        @@lists = nil

        def ==(other)
          other.is_a?(self.class)
        end

        def initialize
          super

          @title = 'New tab'
          refresh
        end

        def respond_to_key(key)
          case key
          when ?g
            scroll_manager.move_to_top
          when ?G
            scroll_manager.move_to_bottom
          when ?j, 14, Curses::Key::DOWN
            scroll_manager.move_down
          when 10
            return true if current_list.nil?
            list_tab = Tab::ListTab.new(current_list.id)
            TabManager.instance.switch(list_tab)
          when ?k, 16, Curses::Key::UP
            scroll_manager.move_up
          else
            return false
          end
          true
        end

        private

        def count
          @@lists.nil? ? 0 : @@lists.count
        end

        def current_list
          @@lists.nil? ? nil : @@lists[scroll_manager.index]
        end

        def offset_from_bottom
          0
        end

        def show_lists
          return if @@lists.nil?

          @@lists.each.with_index(0) do |list, i|
            window.with_color(:black, :magenta) do
              window.setpos(i * 3 + 5, 4)
              window.addstr(' ')
              window.setpos(i * 3 + 6, 4)
              window.addstr(' ')
            end if i == scroll_manager.index

            window.setpos(i * 3 + 5, 6)
            window.addstr("#{list.full_name} (#{list.member_count} members / #{list.subscriber_count} subscribers)")
            window.setpos(i * 3 + 6, 8)
            window.addstr(list.description)
          end
        end

        def scroll_manager
          return @scroll_manager unless @scroll_manager.nil?

          @scroll_manager = ScrollManager.new
          @scroll_manager.delegate = self
          @scroll_manager.after_move { refresh }
          @scroll_manager
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
