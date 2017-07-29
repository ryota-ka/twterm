module Twterm
  class View
    def initialize(window, image)
      @window, @image = window, image
    end

    def at(line, column)
      @line, @column = line, column

      self
    end

    def render
      @image.at(line, column).render(@window)
      @window.refresh

      self
    end

    private

    def column
      @column || 0
    end

    def line
      @line || 0
    end
  end
end
