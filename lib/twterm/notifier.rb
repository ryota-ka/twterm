module Twterm
  class Notifier
    include Singleton
    include Curses

    def initialize
      @window = stdscr.subwin(1, stdscr.maxx, stdscr.maxy - 2, 0)
      @queue = Queue.new

      Thread.new do
        while notification = @queue.pop
          show(notification)
          sleep 3
          show
        end
      end
    end

    def show_error(message)
      notification = Notification::Error.new(message)
      @queue.push(notification)
      self
    end

    def show_message(message)
      notification = Notification::Message.new(message)
      @queue.push(notification)
      self
    end

    def show(notification = nil)
      loop do
        break unless closed?
        sleep 0.5
      end

      @window.clear

      if notification.is_a? Notification::Base
        @window.with_color(notification.fg_color, notification.bg_color) do
          @window.setpos(0, 0)
          @window.addstr(' ' * @window.maxx)
          @window.setpos(0, 1)
          time = notification.time.strftime('[%H:%M:%S]')
          message = notification.show_with_width(@window.maxx)
          @window.addstr("#{time} #{message}")
        end
      end

      @window.refresh
    end
  end
end
