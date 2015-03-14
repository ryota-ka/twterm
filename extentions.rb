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

class Integer
  def format
    to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')
  end
end

class Curses::Window
  def bold(&block)
    attron(Curses::A_BOLD)
    block.call
    attroff(Curses::A_BOLD)
  end

  def with_color(fg, bg = :black, &block)
    color_pair_index = ColorManager.instance.get_color_pair_index(fg, bg)
    attron(Curses.color_pair(color_pair_index))
    block.call
    attroff(Curses.color_pair(color_pair_index))
  end
end
