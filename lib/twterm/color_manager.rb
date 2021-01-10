module Twterm
  class ColorManager
    include Singleton

    COLORS = [:black, :white, :red, :green, :blue, :yellow, :cyan, :magenta, :transparent]
    CURSES_COLORS = {
      black: Curses::COLOR_BLACK,
      white: Curses::COLOR_WHITE,
      red: Curses::COLOR_RED,
      green: Curses::COLOR_GREEN,
      blue: Curses::COLOR_BLUE,
      yellow: Curses::COLOR_YELLOW,
      cyan: Curses::COLOR_CYAN,
      magenta: Curses::COLOR_MAGENTA,
      transparent: -1
    }

    def get_color_pair_index(fg, bg)
      fail ArgumentError,
        'invalid color name for foreground' unless COLORS.include? fg
      fail ArgumentError,
        'invalid color name for background' unless COLORS.include? bg

      return @colors[bg][fg] unless @colors[bg][fg].nil?

      add_color(fg, bg)
    end

    def initialize
      @colors = {
        black: {}, white: {}, red: {}, green: {},
        blue: {}, yellow: {}, cyan: {}, magenta: {},
        transparent: {}
      }
      @count = 0
    end

    private

    def add_color(fg, bg)
      fail ArgumentError,
        'invalid color name for foreground' unless COLORS.include? fg
      fail ArgumentError,
        'invalid color name for background' unless COLORS.include? bg

      @count += 1
      index = @count

      Curses.init_pair(index, CURSES_COLORS[fg], CURSES_COLORS[bg])
      @colors[bg][fg] = index

      index
    end
  end
end
