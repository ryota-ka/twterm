module Twterm
  class Image
    class HorizontalSequentialImage < Twterm::Image
      def initialize(images)
        @images = images
      end

      def -(other)
        append(other)
      end

      def append(image)
        if image.is_a?(self.class)
          @images += image.images
        else
          images << image
        end

        self
      end

      def height
        images.map(&:height).max
      end

      def render(window)
        window.setpos(line, column)
        images
          .zip(images.lazy.map(&:width).scan(column, :+))
          .each { |r, c| r.at(line, c).render(window) }

        self
      end

      def to_s
        images.map(&:to_s).join
      end

      def width
        images.map(&:width).reduce(0, :+)
      end

      protected

      attr_reader :images
    end
  end
end
