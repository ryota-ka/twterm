module Twterm
  class Image
    class StringImage < Twterm::Image
      def initialize(string)
        @string = string
      end

      def height
        1
      end

      def render(window)
        window.setpos(line, column)
        window.addstr(string)
      end

      def to_s
        @string.dup
      end

      def width
        string.width
      end

      private

      attr_reader :string
    end
  end
end
