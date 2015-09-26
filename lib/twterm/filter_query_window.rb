module Twterm
  class FilterQueryWindow
    include Curses
    include Singleton

    def initialize
      @window = stdscr.subwin(1, stdscr.maxx, stdscr.maxy - 1, 0)
    end

    def input
      clear
      stdscr.setpos(stdscr.maxy - 1, 0)
      stdscr.addch '/'

      Curses.timeout = 10
      raw

      chars = []
      str = ''

      loop do
        char = getch

        if char.nil?
          case chars.first
          when 3, 27 # cancel with <C-c> / Esc
            str = ''
            clear
            break
          when 4 # cancel with <C-d> when query is empty
            if str.empty?
              clear
              break
            end
          when 10 # submit with <C-j>
            break
          when 127 # backspace
            if str.empty?
              clear
              break
            end

            str.chop!
            chars = []
            clear
            stdscr.setpos(stdscr.maxy - 1, 0)
            stdscr.addstr("/#{str}")
          when 0..31
            # ignore control codes (\x00 - \x1f)
          else
            str << chars
              .map { |x| x.is_a?(String) ? x.ord : x }
              .pack('c*')
              .force_encoding('utf-8')
            chars = []
          end
        else
          chars << char
        end

        stdscr.setpos(stdscr.maxy - 1, 1)
        stdscr.addstr(str)
      end

      Curses.timeout = 0
      cbreak

      str
    end

    def clear
      stdscr.setpos(stdscr.maxy - 1, 0)
      stdscr.addstr(' ' * window.maxx)
    end

    def resize
      @window.resize(1, stdscr.maxx)
      @window.move(stdscr.maxy - 1, 0)
    end

    private

    attr_reader :window
  end
end
