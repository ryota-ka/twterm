module Twterm
  module Tab
    module Scrollable
      extend Forwardable

      attr_reader :scroller
      def_delegators :scroller, :drawable_items

      def scroller
        return @scroller unless @scroller.nil?

        @scroller = Scroller.new
        @scroller.delegate = self
        @scroller.after_move { refresh }
        @scroller
      end

      private

      class Scroller
        extend Forwardable

        attr_reader :index, :offset

        attr_accessor :delegate
        def_delegators :delegate, :items, :total_item_count, :drawable_item_count

        def after_move(&block)
          add_hook(:after_move, &block)
        end

        def current_item?(i)
          index == offset + i
        end

        def cursor_free?
          !!@cursor_free
        end

        def initialize
          @index = 0
          @offset = 0
          @cursor_free_mode = false
        end

        def drawable_items
          items.drop(offset).take(drawable_item_count)
        end

        def item_appended!
          @index -= 1
          @offset -= 1 if @offset > 0
        end

        def item_prepended!
          @index += 1
          @offset += 1
        end

        def move_down
          return if count == 0 || index == count - 1
          # return when there are no items or cursor is at the bottom

          @index += 1
          @offset += 1 if (cursor_free? || cursor_on_the_downside?) && !last_item_shown?

          hook :after_move
        end

        def move_to_bottom
          return if count == 0 || index == count - 1

          @index = count - 1
          @offset = [count - drawable_item_count + 1, 0].max

          @offset += 1 until last_item_shown?

          hook :after_move
        end

        def move_to_top
          return if count.zero? || index.zero?

          @index = 0
          @offset = 0

          hook :after_move
        end

        def move_up
          return if count.zero? || index.zero?

          @index -= 1
          @offset -= 1 if cursor_on_the_upside? && !first_item_shown?

          hook :after_move
        end

        def nth_item_drawable?(n)
          n.between?(offset, offset + drawable_item_count)
        end

        def set_cursor_free!
          @cursor_free = true
        end

        private

        alias_method :count, :total_item_count

        def add_hook(name, &block)
          @hooks ||= {}
          @hooks[name] = block
        end

        def cursor_on_the_downside?
          drawable_item_count + offset - index < 4
        end

        def cursor_on_the_upside?
          index - offset < 4
        end

        def first_item_shown?
          offset.zero?
        end

        def last_item_shown?
          total_item_count <= offset + drawable_item_count
        end

        def hook(name)
          @hooks[name].call unless @hooks[name].nil?
        end
      end
    end
  end
end
