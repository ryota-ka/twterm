require_relative './between'

module Twterm
  class Image
    class Brackets < Twterm::Image::Between
      def initialize(image)
        super(image, open, close)
      end

      private

      def open
        StringImage.new('[')
      end

      def close
        StringImage.new(']')
      end
    end
  end
end
