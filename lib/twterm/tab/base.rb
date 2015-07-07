module Twterm
  module Tab
    module Base
      include Curses

      attr_reader :window
      attr_accessor :title

      def ==(other)
        self.equal?(other)
      end

      def close
        window.close
      end

      def initialize
        @window = stdscr.subwin(stdscr.maxy - 5, stdscr.maxx - 30, 3, 0)
      end

      def refresh
        return unless refreshable?

        Thread.new do
          refresh_mutex.synchronize do
            window.clear
            update
            window.refresh
          end
        end
      end

      def respond_to_key(_)
        fail NotImplementedError, 'respond_to_key method must be implemented'
      end

      private

      def refresh_mutex
        @refresh_mutex ||= Mutex.new
      end

      def refreshable?
        !(
          refresh_mutex.locked? ||
            closed? ||
            TabManager.instance.current_tab.object_id != object_id
        )
      end

      def update
        fail NotImplementedError, 'update method must be implemented'
      end
    end
  end
end
