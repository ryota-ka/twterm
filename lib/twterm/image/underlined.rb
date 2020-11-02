module Twterm
  class Image
    class Underlined < Twterm::Image
      def initialize(image)
        @image = image
      end

      def height
        image.height
      end

      def render(window)
        window.attron(Curses::A_UNDERLINE)
        image.at(line, column).render(window)
        window.attroff(Curses::A_UNDERLINE)
      end

      def to_s
        "\e[4m#{image}\e[0m"
      end

      def width
        image.width
      end

      private

      attr_reader :image
    end
  end
end
