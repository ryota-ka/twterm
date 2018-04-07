require 'twterm/image/blank_line'
require 'twterm/image/bold'
require 'twterm/image/brackets'
require 'twterm/image/color'
require 'twterm/image/horizontal_sequential_image'
require 'twterm/image/parens'
require 'twterm/image/vertical_sequential_image'

class Twterm::Image
  def initialize(column: 0, line: 0)
    @column, @line = column, line
  end

  def !
    bold
  end

  def |(other)
    VerticalSequentialImage.new([self, other])
  end

  def -(other)
    HorizontalSequentialImage.new([self, other])
  end

  def at(line, column)
    @line, @column = line, column

    self
  end

  def bold(on = true)
    on ? Bold.new(self) : self
  end

  def brackets
    Brackets.new(self)
  end

  def color(fg, bg = :transparent)
    Color.new(self, fg, bg)
  end

  def column
    @column || 0
  end

  def line
    @line || 0
  end

  def parens
    Parens.new(self)
  end
end
