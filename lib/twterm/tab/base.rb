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
        @window = stdscr.subwin(stdscr.maxy - 5, stdscr.maxx, 3, 0)
      end

      def refresh
        Thread.new do
          refresh_mutex.synchronize do
            window.clear

            # avoid misalignment caused by some multibyte-characters
            window.with_color(:black, :transparent) do
              (0...window.maxy).each do |i|
                window.setpos(i, 0)
                window.addch(' ')
              end
            end

            update
            window.refresh
          end if refreshable?
        end
      end

      def respond_to_key(_)
        fail NotImplementedError, 'respond_to_key method must be implemented'
      end

      def title=(title)
        @title = title
        TabManager.instance.refresh_window
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
