require 'twterm/image/between'
require 'twterm/image/blank_line'
require 'twterm/image/bold'
require 'twterm/image/brackets'
require 'twterm/image/color'
require 'twterm/image/dim'
require 'twterm/image/empty'
require 'twterm/image/horizontal_sequential_image'
require 'twterm/image/parens'
require 'twterm/image/string_image'
require 'twterm/image/underlined'
require 'twterm/image/vertical_sequential_image'

class Twterm::Image
  def initialize(column: 0, line: 0)
    @column, @line = column, line
  end

  def _
    underlined
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

  def bold(on = true)
    on ? Bold.new(self) : self
  end

  def brackets
    Brackets.new(self)
  end

  def dim(on = true)
    on ? Dim.new(self) : self
  end

  def self.checkbox(checked)
    string(checked ? '*' : ' ').brackets
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

  def self.remaining_resource(remaining, total, length)
    ratio = remaining * 100 / total
    color =
      if ratio >= 40
        :green
      elsif ratio >= 20
        :yellow
      else
        :red
      end

    bars = string(('|' * (remaining * length / total)).ljust(length)).color(color)

    Between.new(bars, !string('['), !string(']'))
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

  # @param items [Array<Symbol>]
  # @param selected [Symbol]
  #
  # @return [Image]
  def self.toggle_switch(items, selected)
    items
      .map do |item|
        on = item == selected
        string(item.to_s)
          .bold(on)
          .underlined(on)
      end
      .intersperse(string(' | '))
      .reduce(empty) { |acc, x| acc - x }
      .brackets
  end

  def underlined(on = true)
    on ? Underlined.new(self) : self
  end

  def self.whitespace
    string(' ')
  end
end
