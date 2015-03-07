module Tab
  module StatusesTab
    include Base
    include Scrollable
    include AutoReloadable

    def initialize
      super

      @statuses = []
    end

    def push(status)
      fail unless status.is_a? Status

      return if @statuses.any? { |s| s.id == status.id }

      @statuses << status
      status.split(@window.maxx - 4)
      @scrollable_index += 1
      refresh
    end

    def unshift(status)
      fail ArgumentError, 'argument must be an instance of Status class' unless status.is_a? Status

      return if @statuses.any? { |s| s == status }

      @statuses.unshift(status)
      status.split(@window.maxx - 4)
      @scrollable_index -= 1
      @scrollable_offset -= 1 if @scrollable_offset > 0
      refresh
    end

    def reply
      return if highlighted_status.nil?
      Tweetbox.instance.compose(highlighted_status)
    end

    def favorite
      return if highlighted_status.nil?
      if highlighted_status.favorited?
        ClientManager.instance.current.unfavorite(highlighted_status) do
          refresh
        end
      else
        ClientManager.instance.current.favorite(highlighted_status) do
          refresh
        end
      end
    end

    def retweet
      return if highlighted_status.nil?
      ClientManager.instance.current.retweet(highlighted_status) do
        refresh
      end
    end

    def delete_status(status_id)
      @statuses.delete_if do |status|
        status.id == status_id
      end
      refresh
    end

    def show_user
      return if highlighted_status.nil?
      user = highlighted_status.user
      user_tab = Tab::UserTab.new(user)
      TabManager.instance.add_and_show(user_tab)
    end

    def open_link
      return if highlighted_status.nil?
      status = highlighted_status
      urls = status.urls.map(&:expanded_url) + status.media.map(&:expanded_url)
      urls.each { |url| Launchy.open(url) }
    end

    def show_conversation
      return if highlighted_status.nil?
      tab = Tab::ConversationTab.new(highlighted_status)
      TabManager.instance.add_and_show(tab)
    end

    def update
      current_line = 0

      @window.clear

      @statuses.reverse.drop(offset).each.with_index(offset) do |status, i|
        formatted_lines = status.split(@window.maxx - 4).count
        if current_line + formatted_lines + 2 > @window.maxy
          @scrollable_last = i
          break
        end

        posy = current_line

        if index == i
          @window.with_color(:black, :magenta) do
            (formatted_lines + 1).times do |j|
              @window.setpos(posy + j, 0)
              @window.addch(' ')
            end
          end
        end

        @window.setpos(current_line, 2)

        @window.bold do
          @window.with_color(status.user.color) do
            @window.addstr(status.user.name)
          end
        end

        @window.addstr(" (@#{status.user.screen_name}) [#{status.date}] ")

        unless status.retweeted_by.nil?
          @window.addstr('(retweeted by ')
          @window.bold do
            @window.addstr("@#{status.retweeted_by.screen_name}")
          end
          @window.addstr(') ')
        end

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

        status.split(@window.maxx - 4).each do |line|
          current_line += 1
          @window.setpos(current_line, 2)
          @window.addstr(line)
        end

        current_line += 2
      end

      draw_scroll_bar

      @window.refresh

      UserWindow.instance.update(highlighted_status.user) unless highlighted_status.nil?
      show_help
    end

    def respond_to_key(key)
      return true if super

      case key
      when 'c'
        show_conversation
      when 'F'
        favorite
      when 'o'
        open_link
      when 'r'
        reply
      when 'R'
        retweet
      when 'u'
        show_user
      else
        return false
      end
      true
    end

    private

    def highlighted_status
      @statuses[count - index - 1]
    end

    def count
      @statuses.count
    end

    def offset_from_bottom
      return @offset_from_bottom unless @offset_from_bottom.nil?

      height = 0
      @statuses.each.with_index(-1) do |status, i|
        height += status.split(@window.maxx - 4).count + 2
        if height >= @window.maxy
          @offset_from_bottom = i
          return i
        end
      end
      count
    end

    def sort
      @statuses.sort_by!(&:created_at)
    end

    def show_help
      Notifier.instance.show_help '[n] Compose  [r] Reply  [F] Favorite  [R] Retweet  [u] Show user  [w] Close tab  [Q] Quit'
    end
  end
end
