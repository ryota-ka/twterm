require 'twterm/image'

class Twterm::Image::Attr < Twterm::Image
  # @param image [Twterm::Image]
  def initialize(image)
    super()

    @image = image
  end

  def height
    image.height
  end

  def render(window)
    image, attr =
      if image.is_a?(self.class) # fuse attributes when possible
        [image.image, self.attr | image.attr]
      else
        [self.image, self.attr]
      end

    window.attron(attr)
    image.at(line, column).render(window)
    window.attroff(attr)
  end

  def width
    image.width
  end

  protected

  attr_reader :image

  # @abstract
  #
  # @return [Integer]
  def attr
    raise NotImplementedError, '`attr` must be implemented'
  end
end
