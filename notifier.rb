require 'singleton'
require 'bundler'
Bundler.require

class Notifier
  include Singleton
  include Curses

  def initialize
    @window = stdscr.subwin(1, 0, stdscr.maxy - 2, 0)

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
    @window.clear

    color =
      if !@error.empty?
        :red
      elsif !@message.empty?
        :green
      else
        nil
      end

    return if color.nil?

    @window.setpos(0, 0)
    @window.with_color(:white, color) do
      @window.addstr(@error.ljust(@window.maxx))
    end
    @window.refresh
  end
end
