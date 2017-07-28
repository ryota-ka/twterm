module Twterm
  module Tab
    module Scrollable
      extend Forwardable

      attr_reader :scroller
      def_delegators :scroller, :current_item, :drawable_items

      def scroller
        return @scroller unless @scroller.nil?

        @scroller = self.class::Scroller.new(self)
        @scroller.delegate = self
        @scroller.after_move { render }
        @scroller
      end

      # define default behaviour
      # overwrite if necessary
      def total_item_count
        items.count
      end

      class Scroller
        extend Forwardable
        include Publisher

        attr_reader :index, :offset

        attr_accessor :delegate
        def_delegators :delegate, :items, :total_item_count, :drawable_item_count

        def after_move(&block)
          add_hook(:after_move, &block)
        end

        def current_index?(i)
          index == offset + i
        end

        def current_item
          items[index]
        end

        def no_cursor_mode?
          !!@no_cursor_mode
        end

        def initialize(tab)
          @tab = tab

          @index = 0
          @offset = 0
          @no_cursor_mode = false
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
          @offset += 1 unless @index < 4
          # keep cursor position unless it is on the top
        end

        def move_down
          return if count == 0 || index == count - 1 || (no_cursor_mode? && offset + drawable_item_count >= count)
          # return when there are no items or cursor is at the bottom

          @index += 1
          @offset += 1 if (no_cursor_mode? || cursor_on_the_downside?) && !last_item_shown?

          hook :after_move
        end

        def move_to_bottom
          return if count == 0 || index == count - 1

          @index = no_cursor_mode? ? count - drawable_item_count : count - 1
          @offset = [count - drawable_item_count + 1, 0].max

          @offset += 1 until last_item_shown?

          hook :after_move
        end

        def move_to(n)
          if nth_item_drawable?(n)
            @index = n
          else
            @index = @offset = n
          end

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
          n.between?(offset, offset + drawable_item_count - 1)
        end

        def respond_to_key(key)
          k = KeyMapper.instance

          case key
          when k[:general, :page_down]
            10.times { move_down }
          when k[:general, :top]
            move_to_top
          when k[:general, :bottom]
            move_to_bottom
          when k[:general, :down], Curses::Key::DOWN
            move_down
          when k[:general, :up], Curses::Key::UP
            move_up
          when k[:general, :page_up]
            10.times { move_up }
          when k[:cursor, :top_of_window]
            move_to(offset)
          when k[:cursor, :middle_of_window]
            move_to((2 * offset + [drawable_item_count, total_item_count - offset].min - 1) / 2)
          when k[:cursor, :bottom_of_window]
            move_to(offset + [drawable_item_count, total_item_count - offset].min - 1)
          else
            return false
          end

          true
        end

        def set_no_cursor_mode!
          @no_cursor_mode = true
        end

        private

        attr_reader :tab

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

        alias_method :count, :total_item_count
      end
    end
  end
end
