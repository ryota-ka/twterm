require_relative './image/blank_line'
require_relative './image/bold'
require_relative './image/brackets'
require_relative './image/color'
require_relative './image/empty'
require_relative './image/horizontal_sequential_image'
require_relative './image/parens'
require_relative './image/string_image'
require_relative './image/vertical_sequential_image'

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

  def self.blank_line
    BlankLine.new
  end

  def bold
    Bold.new(self)
  end

  def brackets
    Brackets.new(self)
  end

  def self.checkbox(checked)
    string(checked ? 'x' : ' ').brackets
  end

  def color(fg, bg = :transparent)
    Color.new(self, fg, bg)
  end

  def column
    @column || 0
  end

  def self.cursor(height, current)
    color = current ? [:black, :magenta] : [:black]
    VerticalSequentialImage.new([whitespace] * height).color(*color)
  end

  def self.empty
    Empty.new
  end

  def line
    @line || 0
  end

  def self.number(n)
    string(n.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,'))
  end

  def parens
    Parens.new(self)
  end

  def self.plural(n, singular, plural = "#{singular}s")
    string(n == 1 ? singular : plural)
  end

  def self.string(str)
    StringImage.new(str)
  end

  def self.whitespace
    string(' ')
  end
end
