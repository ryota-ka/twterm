module Twterm
  class FilterQueryWindow
    include Curses
    include Singleton

    def initialize
      @window = stdscr.subwin(1, stdscr.maxx, stdscr.maxy - 1, 0)
    end

    def input
      clear

      echo
      stdscr.setpos(stdscr.maxy - 1, 0)
      stdscr.addch '/'

      query = getstr.chomp
      noecho

      query || ''
    end

    def clear
      stdscr.setpos(stdscr.maxy - 1, 0)
      stdscr.addstr(' ' * window.maxx)
    end

    private

    attr_reader :window
  end
end
