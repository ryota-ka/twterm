module Twterm
  module Tab
    module New
      class Search
        include Base
        include Readline
        include Scrollable

        @@queries = []

        def ==(other)
          other.is_a?(self.class)
        end

        def drawable_item_count
          (window.maxy - 6).div(3)
        end

        def initialize
          super

          @title = 'New tab'

          update_saved_search
        end

        def invoke_input
          resetter = proc do
            reset_prog_mode
            sleep 0.1
            Screen.instance.refresh
          end

          input_thread = Thread.new do
            close_screen
            CompletionManager.instance.set_default_mode!
            puts "\ninput search query"
            query = (readline('> ') || '').strip
            resetter.call

            tab = query.nil? || query.empty? ? Tab::New::Search.new : Tab::SearchTab.new(query)
            TabManager.instance.switch(tab)
          end

          App.instance.register_interruption_handler do
            input_thread.kill
            resetter.call
            tab = Tab::New::Search.new
            TabManager.instance.switch(tab)
          end

          input_thread.join
        end

        def items
          ['<Input search query>'] + @@queries
        end

        def respond_to_key(key)
          case key
          when ?d, 4
            10.times { scroller.move_down }
          when ?g
            scroller.move_to_top
          when ?G
            scroller.move_to_bottom
          when 10
            open_search_tab_with_current_query
          when ?j, 14, Curses::Key::DOWN
            scroller.move_down
          when ?k, 16, Curses::Key::UP
            scroller.move_up
          when ?u, 21
            10.times { scroller.move_up }
          else
            return false
          end

          true
        end

        def total_item_count
          @@queries.count + 1
        end

        private

        alias_method :count, :total_item_count

        def open_search_tab_with_current_query
          index = scroller.index

          if index == 0
            invoke_input
          else
            query = @@queries[index - 1]
            tab = Tab::SearchTab.new(query)
            TabManager.instance.switch(tab)
          end
        end

        def update
          offset = scroller.offset

          window.setpos(2, 3)
          window.bold { window.addstr('Open search tab') }

          drawable_items.each.with_index(0) do |query, i|
            line = 3 * i + 5

            window.with_color(:black, :magenta) do
              window.setpos(line, 4)
              window.addstr(' ')
              window.setpos(line + 1, 4)
              window.addstr(' ')
            end if scroller.current_item?(i)

            window.setpos(line, 6)
            window.addstr(query)
          end
        end

        def update_saved_search
          return unless @@queries.empty?

          Client.current.saved_search do |searches|
            @@queries = searches.map(&:query)
            refresh
          end
        end
      end
    end
  end
end
