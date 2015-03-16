module Twterm
  class UserWindow
    include Singleton
    include Curses

    def initialize
      @window = stdscr.subwin(stdscr.maxy - 2, 30, 0, stdscr.maxx - 30)
    end

    def update(user)
      fail ArgumentError, 'argument must be an instance of User class' unless user.is_a? User

      @user = user
      refresh_window
    end

    def refresh_window
      @window.clear

      if @user.nil?
        draw_border
        @window.refresh
        return
      end

      @window.bold do
        @window.setpos(1, 2)
        @window.addstr(@user.name)
        @window.setpos(2, 2)
        @window.addstr("@#{@user.screen_name}")
      end

      @window.setpos(4, 2)
      @window.addstr("#{@user.statuses_count.format} tweets  ".rjust(@window.maxx - 2))
      @window.setpos(5, 2)
      @window.addstr("#{@user.friends_count.format} following  ".rjust(@window.maxx - 2))
      @window.setpos(6, 2)
      @window.addstr("#{@user.followers_count.format} followers  ".rjust(@window.maxx - 2))

      @window.setpos(8, 2)
      @window.addstr('Location:')
      @window.setpos(9, 4)
      @window.addstr(@user.location)

      @window.setpos(10, 2)
      @window.addstr('Website:')
      @window.setpos(11, 4)
      @window.addstr(@user.website)

      @user.description.split_by_width(@window.maxx - 4).each.with_index(0) do |line, i|
        @window.setpos(13 + i, 2)
        @window.addstr(line)
      end

      draw_border

      @window.refresh
    end

    private

    def draw_border
      @window.with_color(:green) do
        @window.maxy.times do |i|
          @window.setpos(i, 0)
          @window.addch('|')
        end
      end
    end
  end
end
