require_relative './../search_query'
require_relative './../search_query_window'

module Twterm
  module Tab
    module Searchable
      include Scrollable
      extend Forwardable

      def_delegators :scroller, :search_query

      class Scroller < Scrollable::Scroller
        extend Forwardable
        include Publisher

        attr_reader :search_query

        def_delegators :search_query_window,
                       :searching_backward!, :searching_backward?,
                       :searching_down!, :searching_down?,
                       :searching_forward!, :searching_forward?,
                       :searching_up!, :searching_up?

        def initialize
          super
          @search_query = SearchQuery.empty
        end

        def find_next
          searching_forward!

          search_query_window.render_last_query
          search
        end

        def find_previous
          searching_backward!

          search_query_window.render_last_query
          search
        end

        def respond_to_key(key)
          k = KeyMapper.instance

          return if super

          case key
          when k[:tab, :find_next]
            find_next
          when k[:tab, :find_previous]
            find_previous
          when k[:tab, :search_down]
            search_down
          when k[:tab, :search_up]
            search_up
          else
            return false
          end

          true
        end

        def search_up
          searching_up!
          searching_forward!
          ask

          return if search_query.empty?

          find_next
        end

        def search_down
          searching_down!
          searching_forward!
          ask

          return if search_query.empty?

          find_next
        end

        private

        def ask
          @search_query = search_query_window.input || SearchQuery.empty
        end

        def search
          @search_query = search_query_window.last_query if search_query.empty?

          if @search_query.empty?
            event = Event::Notification.new(:message, "search query is empty. Press '/' or '?' to start searching.")
            publish(event)
            return
          end

          f = searching_down? ^ searching_forward? ? -> xs { xs.reverse } : -> xs { xs }
          previous_index = index

          xs = [
            *f.(items.each_with_index.drop(index.succ) + items.each_with_index.take(index)),
            [current_item, index]
          ]
          _, index = xs.find { |x, _| search_query === x }

          if index.nil?
            publish(Event::Notification.new(:error, "No matches found: \"#{search_query}\""))
          else
            hit_bottom = Event::Notification.new(:message, 'search hit BOTTOM, continuing at TOP')
            hit_top = Event::Notification.new(:message, 'search hit TOP, continuing at BOTTOM')

            publish(hit_bottom) if (searching_down? ^ searching_backward?) && index <= previous_index
            publish(hit_top) if (searching_up? ^ searching_backward?) && index >= previous_index
            move_to(index)
          end
        end

        def search_query_window
          SearchQueryWindow.instance
        end

        alias_method :count, :total_item_count
      end
    end
  end
end
