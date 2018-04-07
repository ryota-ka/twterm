require 'twterm/image/between'
require 'twterm/image/blank_line'
require 'twterm/image/empty'
require 'twterm/image/parens'
require 'twterm/image/string_image'
require 'twterm/image/vertical_sequential_image'

module Twterm
  class ImageFactory
    def initialize(ambiguous_width)
      @ambiguous_width = ambiguous_width
    end

    def blank_line
      Image::BlankLine.new
    end

    def checkbox(checked)
      string(checked ? '*' : ' ').brackets
    end

    def cursor(height, current)
      color = current ? [:black, :magenta] : [:black]
      Image::VerticalSequentialImage.new([whitespace] * height).color(*color)
    end

    def empty
      Image::Empty.new
    end

    def number(n)
      string(n.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,'))
    end

    def remaining_resource(remaining, total, length)
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

      Image::Between.new(bars, !string('['), !string(']'))
    end

    def plural(n, singular, plural = "#{singular}s")
      string(n == 1 ? singular : plural)
    end

    def string(str)
      Image::StringImage.new(str)
    end

    def whitespace
      string(' ')
    end

    private

    attr_reader :ambiguous_width
  end
end
