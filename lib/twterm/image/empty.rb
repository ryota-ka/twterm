module Twterm
  class Image
    class Empty < Twterm::Image
      def height
        0
      end

      def render(_)
        self
      end

      def to_s
        ''
      end

      def width
        0
      end
    end
  end
end
