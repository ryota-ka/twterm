require 'twterm/string_width_measurer'

module Twterm
  class Image
    class StringImage < Twterm::Image
      def initialize(string, ambiguous = 2)
        @string = string
        @ambiguous = @ambiguous
      end

      def -(other)
        if other.is_a?(self.class)
          self.class.new(string + other.string)
        else
          super
        end
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
        StringWidthMeasurer.new.measure(string, ambiguous)
      end

      protected

      attr_reader :ambiguous, :string
    end
  end
end
