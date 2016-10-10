module Twterm
  class Image
    class Bold < Twterm::Image
      def initialize(image)
        @image = image
      end

      def height
        image.height
      end

      def render(window)
        window.attron(Curses::A_BOLD)
        image.at(line, column).render(window)
        window.attroff(Curses::A_BOLD)
      end

      def to_s
        "\e[1m#{image}\e[0m"
      end

      def width
        image.width
      end

      private

      attr_reader :image
    end
  end
end
