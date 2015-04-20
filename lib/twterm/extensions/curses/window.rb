class Curses::Window
  def bold(&block)
    attron(Curses::A_BOLD)
    block.call
    attroff(Curses::A_BOLD)
  end

  def with_color(fg, bg = :transparent, &block)
    color_pair_index = Twterm::ColorManager.instance.get_color_pair_index(fg, bg)
    attron(Curses.color_pair(color_pair_index))
    block.call
    attroff(Curses.color_pair(color_pair_index))
  end
end
