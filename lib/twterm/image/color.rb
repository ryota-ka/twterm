require 'twterm/image/attr'

module Twterm
  class Image
    class Color < Twterm::Image::Attr
      def initialize(image, fg, bg = :transparent)
        super(image)

        @fg, @bg = fg, bg
      end

      def to_s
        fg_colors = {
          black: 30, red: 31, green: 32, yellow: 33,
          blue: 34, magenta: 35, cyan: 36, white: 37
        }
        bg_colors = {
          black: 40, red: 41, green: 42, yellow: 43,
          blur: 44, magenta: 45, cyan: 46, white: 47
        }

        str = "\e[#{fg_colors[@fg]}m#{image}\e[0m"
        @bg == :transparent ? str : "\e[#{bg_colors[@bg]}m#{str}"
      end

      protected

      def attr
        Curses.color_pair(color_pair_index)
      end

      private

      def color_pair_index
        Twterm::ColorManager.instance.get_color_pair_index(@fg, @bg)
      end
    end
  end
end
