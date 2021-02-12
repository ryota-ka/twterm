require 'twterm/image/attr'

module Twterm
  class Image
    class Bold < Twterm::Image::Attr
      def to_s
        "\e[1m#{image}\e[0m"
      end

      protected

      def attr
        Curses::A_BOLD
      end
    end
  end
end
