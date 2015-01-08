require 'singleton'
require 'bundler'
Bundler.require

class UserWindow
  include Singleton
  include Curses

  def initialize
    @window = stdscr.subwin(0, 30, 0, stdscr.maxx - 30)
  end

  def update(user)
    fail ArgumentError, 'Augument must be a user' unless user.is_a? User
    @user = user
    refresh_window
  end

  def refresh_window
    @window.clear

    @window.attron(A_BOLD)
    @window.setpos(1, 2)
    @window.addstr(@user.name)
    @window.setpos(2, 2)
    @window.addstr("@#{@user.screen_name}")
    @window.attroff(A_BOLD)

    @user.description.split_by_width(@window.maxx - 2).each.with_index(0) do |line, i|
      @window.setpos(4 + i, 2)
      @window.addstr(line)
    end

    draw_border

    @window.refresh
  end

  private

  def draw_border
    @window.attron(color_pair(4))
    @window.maxy.times do |i|
      @window.setpos(i, 0)
      @window.addch('|')
    end
    @window.attroff(color_pair(4))
  end
end
