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
      formatted_lines = status.split(@window.maxx - 3).count
      if current_line + formatted_lines + 3 > @window.maxy
        @last = @offset + i
        break
      end

      posy = current_line

      if @highlight == i
        @window.attron(color_pair(5))
        (formatted_lines + 1).times do |j|
          @window.setpos(posy + j, 0)
          @window.addch(' ')
        end
        @window.attroff(color_pair(5))
      end

      @window.setpos(current_line, 2)

      @window.attron(A_BOLD)
      @window.addstr(status.user.name)
      @window.attroff(A_BOLD)
      @window.addstr(" (@#{status.user.screen_name}) [#{status.created_at}] ")

      if status.favorited?
        @window.attron(color_pair(3))
        @window.addch(' ')
        @window.attroff(color_pair(3))
        @window.addch(' ')
      end

      if status.retweeted?
        @window.attron(color_pair(2))
        @window.addch(' ')
        @window.attroff(color_pair(2))
      end

      status.split(@window.maxx - 3).each do |line|
        current_line += 1
        @window.setpos(current_line, 2)
        @window.addstr(line)
      end

      current_line += 2
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
    Notifier.instance.show_message "Reply to @#{highlighted_status.user.screen_name}"
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
