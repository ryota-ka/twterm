require 'twterm/event/message/info'
require 'twterm/event/message/warning'
require 'twterm/search_query_window'

module Twterm
  module Tab
    module Searchable
      include Scrollable
      extend Forwardable

      def_delegators :scroller, :search_query

      def matches?(_item, _query)
        raise NotImplementedError, '`matches?` method must be implemented'
      end

      class Scroller < Scrollable::Scroller
        extend Forwardable
        include Publisher

        attr_reader :search_query

        def_delegators :search_query_window,
                       :searching_backward!, :searching_backward?,
                       :searching_down!, :searching_down?,
                       :searching_forward!, :searching_forward?,
                       :searching_up!, :searching_up?

        def initialize(*)
          super
          @search_query = ''
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
          @search_query = search_query_window.input || ''
        end

        def search
          @search_query = search_query_window.last_query if search_query.empty?

          if @search_query.empty?
            event = Event::Message::Info.new("search query is empty. Press '/' or '?' to start searching.")
            publish(event)
            return
          end

          f = searching_down? ^ searching_forward? ? -> xs { xs.reverse } : -> xs { xs }
          previous_index = index

          xs = [
            *f.(items.each_with_index.drop(index.succ) + items.each_with_index.take(index)),
            [current_item, index]
          ]
          _, index = xs.find { |x, _| tab.matches?(x, search_query) }

          if index.nil?
            publish(Event::Message::Warning.new("No matches found: \"#{search_query}\""))
          else
            hit_bottom = Event::Message::Info.new('search hit BOTTOM, continuing at TOP')
            hit_top = Event::Message::Info.new('search hit TOP, continuing at BOTTOM')

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
