module Twterm
  module Tab
    module StatusesTab
      include Base
      include Scrollable

      def append(status)
        fail ArgumentError,
          'argument must be an instance of Status class' unless status.is_a? Status

        return if @status_ids.include?(status.id)

        @status_ids.unshift(status.id)
        status.split(window.maxx - 4)
        status.touch!
        scroller.item_appended!
        refresh
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

      def drawable_item_count
        statuses.reverse.drop(scroller.offset).lazy
          .map { |s| s.split(window.maxx - 4).count + 2 }
          .scan(0, :+)
          .select { |l| l < window.maxy }
          .count
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
          reset_grep
        elsif total_item_count == 0
          Notifier.instance.show_error "No matches found: \"#{grep_query}\""
          reset_grep
        else
          Notifier.instance.show_message "#{total_item_count} statuses found: \"#{grep_query}\""
          scroller.move_to_top
          refresh
        end
      end

      def initialize
        super

        @status_ids = []
      end

      def items
        statuses.reverse
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
        status.split(window.maxx - 4)
        status.touch!
        scroller.item_prepended!
        refresh
      end

      def reply
        return if highlighted_status.nil?
        Tweetbox.instance.compose(highlighted_status)
      end

      def reset_grep
        # TODO: replace with more general way (issue #170)
        stdscr.clear
        Screen.instance.refresh

        @grep_query = ''
        refresh
      end

      def respond_to_key(key)
        case key
        when ?c
          show_conversation
        when ?d, 4
          10.times { scroller.move_down }
        when ?D
          destroy_status
        when ?F
          favorite
        when ?g
          scroller.move_to_top
        when ?G
          scroller.move_to_bottom
        when ?j, 14, Curses::Key::DOWN
          scroller.move_down
        when ?k, 16, Curses::Key::UP
          scroller.move_up
        when ?o
          open_link
        when ?r
          reply
        when ?R
          retweet
        when 18
          fetch
        when ?u, 21
          10.times { scroller.move_up }
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

      def total_item_count
        grep_query.empty? ? @status_ids.count : statuses.count
      end

      def update
        line = 0

        scroller.drawable_items.each.with_index(0) do |status, i|
          formatted_lines = status.split(window.maxx - 4).count
          window.with_color(:black, :magenta) do
            (formatted_lines + 1).times do |j|
              window.setpos(line + j, 0)
              window.addch(' ')
            end
          end if scroller.current_item?(i)

          window.setpos(line, 2)

          window.bold do
            window.with_color(status.user.color) do
              window.addstr(status.user.name)
            end
          end

          window.addstr(" (@#{status.user.screen_name}) [#{status.date}] ")

          unless status.retweeted_by.nil?
            window.addstr('(retweeted by ')
            window.bold do
              window.addstr("@#{status.retweeted_by.screen_name}")
            end
            window.addstr(') ')
          end

          if status.favorited?
            window.with_color(:black, :yellow) do
              window.addch(' ')
            end

            window.addch(' ')
          end

          if status.retweeted?
            window.with_color(:black, :green) do
              window.addch(' ')
            end
            window.addch(' ')
          end

          if status.favorite_count > 0
            window.with_color(:yellow) do
              window.addstr("#{status.favorite_count}fav#{status.favorite_count > 1 ? 's' : ''}")
            end
            window.addch(' ')
          end

          if status.retweet_count > 0
            window.with_color(:green) do
              window.addstr("#{status.retweet_count}RT#{status.retweet_count > 1 ? 's' : ''}")
            end
            window.addch(' ')
          end

          status.split(window.maxx - 4).each do |str|
            line += 1
            window.setpos(line, 2)
            window.addstr(str)
          end

          line += 2
        end
      end

      private

      def grep_query
        @grep_query || ''
      end

      def highlighted_status
        statuses[scroller.count - scroller.index - 1]
      end

      def sort
        @status_ids &= Status.all.map(&:id)
        @status_ids.sort_by! { |id| Status.find(id).appeared_at }
      end
    end
  end
end
