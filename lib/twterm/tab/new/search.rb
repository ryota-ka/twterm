module Twterm
  module Tab
    module New
      class Search
        include Base
        include Readline
        include FilterableList
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

            tab = query.nil? || query.empty? ? Tab::New::Search.new : Tab::Statuses::Search.new(query)
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
          if filter_query.empty?
            ['<Input search query>'] + @@queries
          else
            @@queries.select { |q| q.matches?(filter_query) }
          end
        end

        def respond_to_key(key)
          return true if scroller.respond_to_key(key)

          case key
          when 10
            open_search_tab_with_current_query
          when ?q
            reset_filter
          when ?/
            filter
          else
            return false
          end

          true
        end

        def total_item_count
          items.count
        end

        private

        alias_method :count, :total_item_count

        def open_search_tab_with_current_query
          index = scroller.index

          if filter_query.empty? && index.zero?
            invoke_input
          else
            query = items[index]
            tab = Tab::Statuses::Search.new(query)
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

          Client.current.saved_search.then do |searches|
            @@queries = searches.map(&:query)
            refresh
          end
        end
      end
    end
  end
end
