module Twterm
  class Image
    class BlankLine < Twterm::Image
      def height
        1
      end

      def render(_)
        self
      end

      def to_s
        "\n"
      end

      def width
        0
      end
    end
  end
end
