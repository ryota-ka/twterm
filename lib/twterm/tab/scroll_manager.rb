module Twterm
  module Tab
    class ScrollManager
      attr_reader :index, :offset
      attr_accessor :last

      def initialize
        @index = 0
        @offset = 0
        @last = 0
      end

      def after_move(&block)
        add_hook(:after_move, &block)
      end

      def count
        @count_tracker.call
      end

      def item_prepended!
        @index += 1
        @offset += 1
      end

      def item_appended!
        @index -= 1
        @offset -= 1 if @offset > 0
      end

      def move_down
        return if count == 0 || index == count - 1

        @index = [index + 1, count - 1].min
        @offset = [
          offset + 1,
          count - 1,
          count - offset_from_bottom
        ].min if index > last - 4

        hook :after_move
      end

      def move_up
        return if count == 0 || index == 0

        @index = [index - 1, 0].max
        @offset = [offset - 1, 0].max if index - 4 < offset

        hook :after_move
      end

      def move_to_bottom
        return if count == 0 || index == count - 1

        @index = count - 1
        @offset = count - 1 - offset_from_bottom

        hook :after_move
      end

      def move_to_top
        return if count == 0 || index == 0

        @index = 0
        @offset = 0

        hook :after_move
      end

      def offset_from_bottom
        @offset_from_bottom_tracker.call
      end

      def register_count_tracker(&block)
        @count_tracker = block
      end

      def register_offset_from_bottom_tracker(&block)
        @offset_from_bottom_tracker = block
      end

      private

      def add_hook(name, &block)
        @hooks ||= {}
        @hooks[name] = block
      end

      def hook(name)
        @hooks[name].call unless @hooks[name].nil?
      end
    end
  end
end
