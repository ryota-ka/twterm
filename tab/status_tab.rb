module Tab
  module StatusTab
    include Base

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
      fail unless status.is_a? Status

      @statuses << status
      @highlight += 1 unless @highlight == 0
      refresh_window

      UserWindow.instance.update(highlighted_status.user) unless highlighted_status.nil?
    end

    def refresh_window
      current_line = 0

      @window.clear
      @statuses.reverse.drop(@offset).each.with_index(1 + @offset) do |status, i|
        formatted_lines = status.split(@window.maxx - 3).count
        if current_line + formatted_lines + 3 > @window.maxy
          @last = i
          break
        end

        posy = current_line

        if @highlight == i
          @window.with_color(:black, :magenta) do
            (formatted_lines + 1).times do |j|
              @window.setpos(posy + j, 0)
              @window.addch(' ')
            end
          end
        end

        @window.setpos(current_line, 2)

        @window.bold do
          @window.addstr(status.user.name)
        end

        @window.addstr(" (@#{status.user.screen_name}) [#{status.date}] ")

        if status.favorited?
          @window.with_color(:black, :yellow) do
            @window.addch(' ')
          end

          @window.addch(' ')
        end

        if status.retweeted?
          @window.with_color(:black, :green) do
            @window.addch(' ')
          end
          @window.addch(' ')
        end

        if status.favorite_count > 0
          @window.with_color(:yellow) do
            @window.addstr("#{status.favorite_count}fav#{status.favorite_count > 1 ? 's' : ''}")
          end
          @window.addch(' ')
        end

        if status.retweet_count > 0
          @window.with_color(:green) do
            @window.addstr("#{status.retweet_count}RT#{status.retweet_count > 1 ? 's' : ''}")
          end
          @window.addch(' ')
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
      return if @statuses.empty?

      @highlight = [@highlight - lines, 1].max
      @offset = [@offset - 1, 0].max if @highlight - 4 < @offset
      refresh_window

      UserWindow.instance.update(highlighted_status.user)
    end

    def move_down(lines = 1)
      return if @statuses.empty?

      @highlight = [@highlight + lines, @statuses.count].min
      @offset = [
        @offset + 1,
        @statuses.count,
        @statuses.count - offset_from_bottom
      ].min if @highlight > @last - 4
      refresh_window

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
      @offset = @statuses.count - offset_from_bottom
      refresh_window

      UserWindow.instance.update(highlighted_status.user)
    end

    def reply
      Notifier.instance.show_message "Reply to @#{highlighted_status.user.screen_name}"
      Tweetbox.instance.compose(highlighted_status)
    end

    def favorite
      if highlighted_status.favorited?
        ClientManager.instance.current.unfavorite(highlighted_status) do
          refresh_window
        end
      else
        ClientManager.instance.current.favorite(highlighted_status) do
          refresh_window
        end
      end
    end

    def retweet
      ClientManager.instance.current.retweet(highlighted_status) do
        refresh_window
      end
    end

    def delete_status(status_id)
      @statuses.delete_if do |status|
        status.id == status_id
      end
      refresh_window
    end

    private

    def highlighted_status
      @statuses[@statuses.count - @highlight]
    end

    def offset_from_bottom
      return @offset_from_bottom unless @offset_from_bottom.nil?

      height = 0
      @statuses.each.with_index(0) do |status, i|
        height += status.split(@window.maxx - 3).count + 2
        Twterm::Config[:hfb] = i
        return i if height >= @window.maxy
      end
    end
  end
end
