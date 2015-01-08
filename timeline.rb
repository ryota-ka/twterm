require 'singleton'
require 'date'
require 'bundler'
Bundler.require

class Timeline
  include Singleton
  include Curses

  def initialize
    @window = stdscr.subwin(stdscr.maxy - 3, stdscr.maxx - 30, 3, 0)
    @window.scrollok(true)

    @highlight = 0
    @offset = 0
    @last = 0
    stdscr.refresh

    @statuses = []
  end

  def push(status)
    raise unless status.is_a? Status

    @statuses << status
    @highlight += 1 unless @highlight == 0
    refresh_window

    UserWindow.instance.update(highlighted_status.user) unless highlighted_status.nil?
  end

  def refresh_window
    current_line = 0

    @window.clear
    @statuses.reverse.drop(@offset).each.with_index(1) do |status, i|
      formatted_lines = status.formatted_lines(@window.maxx)
      puts formatted_lines
      if current_line + formatted_lines + 3 > @window.maxy
        @last = @offset + i
        break
      end

      @window.setpos(current_line, 0)

      if @highlight == i
        @window.attron(A_REVERSE)
        @window.attron(A_BOLD)
      end

      @window.attron(color_pair(3)) if status.favorited?

      @window.addstr("#{status.user.name} (@#{status.user.screen_name}) [#{status.created_at}]".mb_ljust(@window.maxx))
      @window.addstr(status.format(@window.maxx))

      @window.attroff(color_pair(3))

      if @highlight == i
        @window.attroff(A_REVERSE)
        @window.attroff(A_BOLD)
      end

      current_line += formatted_lines + 2
    end
    @window.refresh
  end

  def move_up(lines = 1)
    @highlight = [@highlight - lines, 1].max
    @offset = [@offset - 1, 0].max if @highlight - 3 <= @offset
    refresh_window

    UserWindow.instance.update(highlighted_status.user)
  end

  def move_down(lines = 1)
    @highlight = [@highlight + lines, @statuses.count].min
    @offset = [@offset + 1, @statuses.count - 1].min if @highlight + 3 >= @last
    refresh_window

    UserWindow.instance.update(highlighted_status.user)
  end

  def move_to_top
    @highlight = 1
    @offset = 0
    refresh_window

    UserWindow.instance.update(highlighted_status.user)
  end

  def move_to_bottom
    @highlight = @statuses.count
    @offset = @statuses.count - 1
    refresh_window

    UserWindow.instance.update(highlighted_status.user)
  end

  def reply
    Tweetbox.instance.compose(highlighted_status)
  end

  def favorite
    ClientManager.instance.current.favorite(highlighted_status) do
      @window.refresh
    end
  end

  def highlighted_status
    @statuses[@statuses.count - @highlight]
  end
end
