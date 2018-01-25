require 'concurrent'

require 'twterm/tab/base'
require 'twterm/tab/loadable'

module Twterm
  module Tab
    module New
      class Search < Base
        include Loadable
        include Readline
        include Searchable

        @@queries = Concurrent::Array.new

        def ==(other)
          other.is_a?(self.class)
        end

        def drawable_item_count
          (window.maxy - 6).div(3)
        end

        def initialize(app, client)
          super(app, client)

          update_saved_search
        end

        def invoke_input
          resetter = proc do
            reset_prog_mode
            sleep 0.1
            app.screen.refresh
          end

          input_thread = Thread.new do
            close_screen
            app.completion_manager.set_search_mode!
            puts "\ninput search query"
            query = (readline('> ', true) || '').strip
            resetter.call

            tab = query.nil? || query.empty? ? Tab::New::Search.new(app, client) : Tab::Statuses::Search.new(app, client, query)
            app.tab_manager.switch(tab)
          end

          app.register_interruption_handler do
            input_thread.kill
            resetter.call
            tab = Tab::New::Search.new
            app.tab_manager.switch(tab)
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
            tab = Tab::Statuses::Search.new(app, client, query)
            app.tab_manager.switch(tab)
          end
        end

        def image
          [
            *drawable_items
              .map.with_index(0) { |query, i|
                curr = scroller.current_index?(i)
                Image.cursor(1, curr) - Image.whitespace - Image.string(query).bold(curr)
              },
            (Image.string('  Loading saved searches...') unless initially_loaded?),
          ]
            .reject(&:nil?)
            .intersperse(Image.blank_line)
            .reduce(Image.empty, :|)
        end

        def update_saved_search
          client.saved_search.then do |searches|
            @@queries = searches.map(&:query)
            initially_loaded!
          end
        end
      end
    end
  end
end
