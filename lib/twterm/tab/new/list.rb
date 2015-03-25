module Twterm
  module Tab
    module New
      class List
        include Base
        include Scrollable

        @@lists = nil

        def initialize
          super

          @title = 'New tab'
        end

        def respond_to_key(key)
          return true if super

          case key
          when 10
            return true if current_list.nil?
            list_tab = Tab::ListTab.new(current_list)
            TabManager.instance.switch(list_tab)
          else
            return false
          end
          true
        end

        def ==(other)
          other.is_a?(self.class)
        end

        private

        def current_list
          @@lists.nil? ? nil : @@lists[index]
        end

        def update
          @window.clear

          @window.bold do
            @window.setpos(2, 3)
            @window.addstr('Open list tab')
          end

          Thread.new do
            Notifier.instance.show_message('Loading lists ...')
            Client.current.lists do |lists|
              @@lists = lists.sort_by(&:full_name)
              show_lists
              update_scrollbar_length
              @window.refresh
            end
          end if @@lists.nil?

          show_lists
          draw_scroll_bar

          @window.refresh
        end

        def show_lists
          return if @@lists.nil?

          @@lists.each.with_index(0) do |list, i|
            @window.with_color(:black, :magenta) do
              @window.setpos(i * 3 + 5, 4)
              @window.addstr(' ')
              @window.setpos(i * 3 + 6, 4)
              @window.addstr(' ')
            end if i == index

            @window.setpos(i * 3 + 5, 6)
            @window.addstr("#{list.full_name} (#{list.member_count} members / #{list.subscriber_count} subscribers)")
            @window.setpos(i * 3 + 6, 8)
            @window.addstr(list.description)
          end
        end

        def count
          @@lists.nil? ? 0 : @@lists.count
        end
      end
    end
  end
end
