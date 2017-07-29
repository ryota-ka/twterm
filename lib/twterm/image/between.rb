class Twterm::Image
  class Between < Twterm::Image
    def initialize(image, open, close)
      @image, @open, @close = image, open, close
    end

    def height
      1
    end

    def render(window)
      open.at(line, column).render(window)
      image.at(line, column + open.width).render(window)
      close.at(line, column + open.width + image.width).render(window)

      self
    end

    def to_s
      "#{open}#{image}#{close}"
    end

    def width
      [open, image, close].map(&:width).reduce(0, :+)
    end

    private

    attr_reader :open, :close, :image
  end
end
