module Tab
  module Scrollable
    include Base

    def initialize
      super

      @scrollable_index = 0
      @scrollable_count = 0
      @scrollable_offset = 0
      @scrollable_last = 0
    end

    def respond_to_key(key)
      case key
      when 'g'
        move_to_top
      when 'G'
        move_to_bottom
      when 'j', 14, Key::DOWN
        move_down
      when 'k', 16, Key::UP
        move_up
      when 4
        move_down(10)
      when 21
        move_up(10)
      else
        return false
      end
      true
    end

    def index
      @scrollable_index
    end

    def count
      @scrollable_count
    end

    def offset
      @scrollable_offset
    end

    def last
      @scrollable_last
    end

    def move_up(amount = 1)
      return if count == 0 || index == 0

      @scrollable_index = [index - amount, 0].max
      @scrollable_offset = [offset - 1, 0].max if index - 4 < offset
      refresh
    end

    def move_down(amount = 1)
      return if count == 0 || index == count - 1

      @scrollable_index = [index + amount, count - 1].min
      @scrollable_offset = [
        offset + 1,
        count - 1,
        count - offset_from_bottom
      ].min if index > last - 4

      refresh
    end

    def move_to_top
      return if count == 0 || index == 0

      @scrollable_index = 0
      @scrollable_offset = 0
      refresh
    end

    def move_to_bottom
      return if count == 0 || index == count - 1

      @scrollable_index = count - 1
      @scrollable_offset = count - 1 - offset_from_bottom
      refresh
    end

    def offset_from_bottom
      0
    end

    def draw_scroll_bar
      return if count == 0

      height = @window.maxy
      length = [height * (last - index + 1) / count, 1].max
      top = height * index / count

      @window.with_color(:black, :white) do
        length.times do |i|
          @window.setpos(top + i, @window.maxx - 1)
          @window.addch(' ')
        end
      end
    end
  end
end
