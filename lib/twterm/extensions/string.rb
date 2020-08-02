require 'word_wrap'
require 'word_wrap/core_ext'

class String
  def width
    each_char.map { |c| c.bytesize == 1 ? 1 : 2 }.reduce(0, &:+)
  end

  def split_by_width(width)
    (self.fit width).split "\n"
  end
end

=begin
class String
  def width
    each_char.map { |c| c.bytesize == 1 ? 1 : 2 }.reduce(0, &:+)
  end

  def split_by_width(width)
    cnt = 0
    str = ''
    chunks = []

    each_char do |c|
      if c == "\n"
        chunks << str
        str = ''
        cnt = 0
        next
      end

      cnt += c.width
      if cnt > width
        chunks << str
        str = ''
        cnt = 0
      end
      str << c unless str.empty? && c == ' '
    end
    chunks << str unless str.empty?
    chunks
  end
end
=end
