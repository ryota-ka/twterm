module Twterm
  module Tab
    module Base
      include Curses

      attr_accessor :title

      def initialize
        @window = stdscr.subwin(stdscr.maxy - 5, stdscr.maxx - 30, 3, 0)
      end

      def refresh
        return if @refreshing || closed? || TabManager.instance.current_tab.object_id != object_id

        @refreshing = true
        Thread.new do
          update
          @refreshing = false
        end
      end

      def close
        @window.close
      end

      def respond_to_key(_)
        fail NotImplementedError, 'respond_to_key method must be implemented'
      end

      def ==(other)
        self.equal?(other)
      end

      private

      def update
        fail NotImplementedError, 'update method must be implemented'
      end
    end
  end
end
