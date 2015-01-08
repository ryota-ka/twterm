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

  def clear
    @message = ''
    refresh_window
  end

  def refresh_window
    @window.clear

    unless @message.empty?
      @window.setpos(0, 0)
      @window.attron(color_pair(2))
      @window.addstr(@message.ljust(stdscr.maxx))
      @window.attroff(color_pair(2))
    end

    @window.refresh
  end
end
