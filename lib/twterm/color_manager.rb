module Twterm
  class ColorManager
    include Singleton
    include Curses

    COLORS = [:black, :white, :red, :green, :blue, :yellow, :cyan, :magenta, :transparent]
    CURSES_COLORS = {
      black: COLOR_BLACK,
      white: COLOR_WHITE,
      red: COLOR_RED,
      green: COLOR_GREEN,
      blue: COLOR_BLUE,
      yellow: COLOR_YELLOW,
      cyan: COLOR_CYAN,
      magenta: COLOR_MAGENTA,
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
