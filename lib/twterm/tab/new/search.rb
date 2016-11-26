require 'twterm/tab/base'

module Twterm
  module Tab
    module New
      class Search < Base
        include Readline
        include Searchable

        @@queries = []

        def ==(other)
          other.is_a?(self.class)
        end

        def drawable_item_count
          (window.maxy - 6).div(3)
        end

        def initialize
          super

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
          ['<Input search query>', *@@queries]
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

        def title
          'New tab'.freeze
        end

        def total_item_count
          items.count
        end

        private

        alias_method :count, :total_item_count

        def open_search_tab_with_current_query
          index = scroller.index

          if search_query.empty? && index.zero?
            invoke_input
          else
            query = items[index]
            tab = Tab::Statuses::Search.new(query)
            TabManager.instance.switch(tab)
          end
        end

        def image
          drawable_items
            .map.with_index(0) { |query, i|
              Image.cursor(1, scroller.current_index?(i)) - Image.whitespace - Image.string(query)
            }
            .intersperse(Image.blank_line)
            .reduce(Image.empty, :|)
        end

        def update_saved_search
          return unless @@queries.empty?

          Client.current.saved_search.then do |searches|
            @@queries = searches.map(&:query)
            render
          end
        end
      end
    end
  end
end
