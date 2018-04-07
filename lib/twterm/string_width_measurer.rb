require 'unicode/display_width'

module Twterm
  class StringWidthMeasurer
    def measure(string, ambiguous_width)
      Unicode::DisplayWidth.of(string, ambiguous_width, {}, emoji: true)
    end

    @@cache = {}

    def split(string, width, ambiguous_width)
      cache = @@cache[{ s: string, w: width, amb: ambiguous_width }]
      return cache unless cache.nil?

      cnt = 0
      str = ''
      chunks = []

      string.each_char do |c|
        if c == "\n"
          chunks << str
          str = ''
          cnt = 0
          next
        end

        cnt += measure(c, ambiguous_width)
        if cnt > width
          chunks << str
          str = ''
          cnt = 0
        end
        str << c unless str.empty? && c == ' '
      end
      chunks << str unless str.empty?

      @@cache[{ s: string, w: width, amb: ambiguous_width }] = chunks

      chunks
    end
  end
end
