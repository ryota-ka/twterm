require 'singleton'
require 'bundler'
Bundler.require

class Notifier
  include Singleton
  include Curses

  def initialize
    @window = stdscr.subwin(1, 0, stdscr.maxy - 2, 0)

    @message = ''
  end

  def show_message(message)
    @message = message
    refresh_window
  end

  def show_error(message)
  end

  def clear
    @message = ''
    refresh_window
  end

  def refresh_window
    @window.clear

    unless @message.empty?
      @window.setpos(0, 0)
      @window.with_color(:black, :green) do
        @window.addstr(@message.ljust(stdscr.maxx))
      end
    end

    @window.refresh
  end
end
