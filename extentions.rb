class String
  def mb_ljust(width, padding = ' ')
    output_width = each_char.map { |c| c.bytesize == 1 ? 1 : 2 }.reduce(0, &:+)
    padding_size = [0, width - output_width].max
    self + padding * padding_size
  end

  def width
    each_char.map { |c| c.bytesize == 1 ? 1 : 2 }.reduce(0, &:+)
  end

  def split_by_width(width)
    cnt = 0
    str = ''
    chunks = []

    each_char do |c|
      cnt += c.width
      if cnt > width
        chunks << str
        str = ''
        cnt = 0
      end
      str << c
    end
    chunks << str unless str.empty?
    chunks
  end
end

class Integer
  def format
    to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')
  end
end
