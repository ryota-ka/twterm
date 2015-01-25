module Tab
  module Scrollable
    include Base

    attr_reader :index, :count, :offset, :last

    def initialize
      super

      @index = 0
      @count = 0
      @offset = 0
      @last = 0
    end

    def move_up(amount = 1)
      return if count == 0 || index == 0

      @index = [index - amount, 0].max
      @offset = [offset - 1, 0].max if index - 4 < offset
      refresh
    end

    def move_down(amount = 1)
      return if count == 0 || index == count - 1

      @index = [index + amount, count - 1].min
      @offset = [
        offset + 1,
        count - 1,
        count - offset_from_bottom
      ].min if index > last - 4

      refresh
    end

    def move_to_top
      return if count == 0 || index == 0

      @index = 0
      @offset = 0
      refresh
    end

    def move_to_bottom
      return if count == 0 || index == count - 1

      @index = count - 1
      @offset = count - 1 - offset_from_bottom
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
