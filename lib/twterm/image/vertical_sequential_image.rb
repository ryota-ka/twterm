module Twterm
  class Image
    class VerticalSequentialImage < Twterm::Image
      def initialize(images)
        @images = images
      end

      def |(other)
        append(other)
      end

      def append(image)
        images << image
        self
      end

      def height
        images.map(&:height).reduce(0, :+)
      end

      def render(window)
        window.setpos(line, column)
        images
          .zip(images.lazy.map(&:height).scan(line, :+))
          .each { |r, l| r.at(l, column).render(window) }

        self
      end

      def to_s
        images.map(&:to_s).join("\n")
      end

      def width
        images.map(&:width).max
      end

      protected

      attr_reader :images
    end
  end
end
