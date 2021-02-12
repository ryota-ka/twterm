require 'twterm/image/attr'

module Twterm
  class Image
    class Underlined < Twterm::Image::Attr
      def to_s
        "\e[4m#{image}\e[0m"
      end

      protected

      def attr
        Curses::A_UNDERLINE
      end
    end
  end
end
