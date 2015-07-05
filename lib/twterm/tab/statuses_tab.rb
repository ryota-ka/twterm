module Twterm
  module Tab
    module StatusesTab
      include Base

      def append(status)
        fail ArgumentError,
          'argument must be an instance of Status class' unless status.is_a? Status

        return if @status_ids.include?(status.id)

        @status_ids.unshift(status.id)
        status.split(@window.maxx - 4)
        status.touch!
        scroll_manager.item_appended!
        refresh
      end

      def count
        @status_ids.count
      end

      def delete(status_id)
        @status_ids.delete(status_id)
        refresh
      end

      def destroy_status
        status = highlighted_status

        Client.current.destroy_status(status) do
          delete(status.id)
          refresh
        end
      end

      def favorite
        return if highlighted_status.nil?

        method_name = highlighted_status.favorited ? :unfavorite : :favorite
        Client.current.method(method_name).call(highlighted_status) { refresh }
      end

      def fetch
        fail NotImplementedError, 'fetch method must be implemented'
      end

      def grep
        reset_grep

        Curses.echo
        Curses.setpos(stdscr.maxy - 1, 0)
        Curses.stdscr.addch '/'
        @grep_query = Curses.getstr.chomp
        Curses.noecho

        if grep_query.empty?
          # do nothing
        elsif count == 0
          Notifier.instance.show_error "No matches found: \"#{grep_query}\""
          @grep_query = ''
        else
          Notifier.instance.show_message "#{count} statuses found: \"#{grep_query}\""
        end

        refresh
      end

      def grep_query
        @grep_query || ''
      end

      def initialize
        super

        @status_ids = []
      end

      def open_link
        return if highlighted_status.nil?

        status = highlighted_status
        urls = status.urls.map(&:expanded_url) + status.media.map(&:expanded_url)
        urls.each(&Launchy.method(:open))
      end

      def prepend(status)
        fail unless status.is_a? Status

        return if @status_ids.include?(status.id)

        @status_ids << status.id
        status.split(@window.maxx - 4)
        status.touch!
        scroll_manager.item_prepended!
        refresh
      end

      def reply
        return if highlighted_status.nil?
        Tweetbox.instance.compose(highlighted_status)
      end

      def reset_grep
        @grep_query = ''
        refresh
      end

      def respond_to_key(key)
        case key
        when ?c
          show_conversation
        when ?d
          10.times { scroll_manager.move_down }
        when ?D
          destroy_status
        when ?F
          favorite
        when ?g
          scroll_manager.move_to_top
        when ?G
          scroll_manager.move_to_bottom
        when ?j, 14, Curses::Key::DOWN
          scroll_manager.move_down
        when ?k, 16, Curses::Key::UP
          scroll_manager.move_up
        when ?o
          open_link
        when ?r
          reply
        when ?R
          retweet
        when 18
          fetch
        when ?u
          10.times { scroll_manager.move_up }
        when ?U
          show_user
        when ?/
          grep
        when ?q
          reset_grep
        else
          return false
        end
        true
      end

      def retweet
        return if highlighted_status.nil?
        Client.current.retweet(highlighted_status) do
          refresh
        end
      end

      def show_conversation
        return if highlighted_status.nil?
        tab = Tab::ConversationTab.new(highlighted_status.id)
        TabManager.instance.add_and_show(tab)
      end

      def show_user
        return if highlighted_status.nil?
        user = highlighted_status.user
        user_tab = Tab::UserTab.new(user.id)
        TabManager.instance.add_and_show(user_tab)
      end

      def statuses
        statuses = @status_ids.map { |id| Status.find(id) }.reject(&:nil?)
        @status_ids = statuses.map(&:id)

        if grep_query.empty?
          statuses
        else
          statuses.select { |s| s.grepped_with?(grep_query) }
        end
      end

      def touch_statuses
        statuses.reverse.take(100).each(&:touch!)
      end

      def update
        current_line = 0

        @window.clear

        offset = scroll_manager.offset
        index = scroll_manager.index

        return if offset < 0

        statuses.reverse.drop(offset).each.with_index(offset) do |status, i|
          formatted_lines = status.split(@window.maxx - 4).count
          if current_line + formatted_lines + 2 > @window.maxy
            scroll_manager.last = i
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

        @window.refresh

        UserWindow.instance.update(highlighted_status.user) unless highlighted_status.nil?
        show_help
      end

      private

      def highlighted_status
        id = @status_ids[scroll_manager.count - scroll_manager.index - 1]
        Status.find(id)
      end

      def offset_from_bottom
        return @offset_from_bottom unless @offset_from_bottom.nil?

        height = 0
        statuses.each.with_index(-1) do |status, i|
          height += status.split(@window.maxx - 4).count + 2
          if height >= @window.maxy
            @offset_from_bottom = i
            return i
          end
        end
        count
      end

      def scroll_manager
        return @scroll_manager unless @scroll_manager.nil?

        @scroll_manager = ScrollManager.new
        @scroll_manager.delegate = self
        @scroll_manager.after_move { refresh }
        @scroll_manager
      end

      def show_help
        Notifier.instance.show_help '[n] Compose  [r] Reply  [F] Favorite  [R] Retweet  [U] Show user  [N] Open new tab  [w] Close tab  [Q] Quit'
      end

      def sort
        @status_ids &= Status.all.map(&:id)
        @status_ids.sort_by! { |id| Status.find(id).appeared_at }
      end
    end
  end
end
