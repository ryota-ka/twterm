require 'singleton'
require 'bundler'
Bundler.require

class Notifier
  include Singleton
  include Curses

  def initialize
    @window = stdscr.subwin(1, stdscr.maxx, stdscr.maxy - 1, 0)

    @message = ''
    @error = ''
  end

  def show_message(message)
    @message = message
    refresh_window
  end

  def show_error(message, duration = 2)
    Thread.new do
      @error = message
      refresh_window
      sleep duration

      @error = ''
      show_message(@message)
    end
  end

  def clear
    @message = ''
    refresh_window
  end

  def refresh_window
    return if closed?

    @window.clear
    @window.setpos(0, 0)

    if !@error.empty?
      @window.with_color(:white, :red) do
        @window.addstr(@error.ljust(@window.maxx))
      end
    elsif !@message.empty?
      @window.with_color(:black, :green) do
        @window.addstr(@message.ljust(@window.maxx))
      end
    else
      nil
    end

    @window.refresh
  end
end
