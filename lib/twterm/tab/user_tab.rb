module Twterm
  module Tab
    class UserTab
      include Base
      include Dumpable
      include Scrollable

      attr_reader :user_id

      def dump
        user_id
      end

      def drawable_item_count
        (window.maxy - 12).div(2)
      end

      def fetch
        update
      end

      def initialize(user_id)
        super()

        @user_id = user_id
      end

      def items
        %i(
          open_timeline_tab
          open_website
          follow_or_unfollow
        )
      end

      def respond_to_key(key)
        case key
        when ?f
        when ?d, 4
          10.times { scroller.move_down }
        when ?F
          follow
        when ?g
          scroller.move_to_top
        when ?G
          scroller.move_to_bottom
        when ?j, 14, Curses::Key::DOWN
          scroller.move_down
        when 10
          perform_selected_action
        when ?k, 16, Curses::Key::UP
          scroller.move_up
        when ?t
          open_timeline_tab
        when ?u, 21
          10.times { scroller.move_up }
        when ?W
          open_website
        else
          return false
        end

        true
      end

      private

      def follow
        Client.current.follow(user_id) do |users|
          refresh

          user = users.first
          msg = "Followed @#{user.screen_name}"
          Notifier.instance.show_message msg
        end
      end

      def open_timeline_tab
        tab = Tab::UserTimelineTab.new(user_id)
        TabManager.instance.add_and_show(tab)
      end

      def open_website
        if user.website.nil?
          Notifier.instance.show_error 'No website'
          return
        end

        Launchy.open(user.website)
      rescue Launchy::CommandNotFoundError
        Notifier.instance.show_error 'Browser not found'
      end

      def perform_selected_action
        case scroller.current_item
        when :follow_or_unfollow
          user.following? ? unfollow : follow
        when :open_timeline_tab
          open_timeline_tab
        when :open_website
          open_website
        end
      end

      def unfollow
        Client.current.unfollow(user_id) do |users|
          refresh

          user = users.first
          msg = "Unfollowed @#{user.screen_name}"
          Notifier.instance.show_message msg
        end
      end

      def update
        User.find_or_fetch(user_id) do |user|
          @title = "@#{user.screen_name}"

          window.setpos(2, 3)
          window.bold { window.addstr(user.name) }
          window.addstr(" (@#{user.screen_name})")

          window.setpos(4, 5)
          text, color = user.following? ? ['[following]', :green] : ['[not following]', :red]
          window.with_color(color) { window.addstr(text) }

          window.setpos(6, 5)
          window.addstr("#{user.statuses_count.format} tweets")
          window.setpos(7, 5)
          window.addstr("#{user.friends_count.format} following")
          window.setpos(8, 5)
          window.addstr("#{user.followers_count.format} followers")

          window.setpos(6, 25)
          window.addstr("Location: #{user.location}")
          window.setpos(7, 25)
          window.addstr("Website: #{user.website}")

          current_line = 11
          drawable_items.each.with_index(0) do |item, i|
            if scroller.current_item? i
              window.setpos(current_line, 3)
              window.with_color(:black, :magenta) { window.addch(' ') }
            end

            window.setpos(current_line, 5)
            case item
            when :follow_or_unfollow
              if user.following?
                window.addstr('    Unfollow this user')
              else
                window.addstr('[ ] Follow this user')
                window.setpos(current_line, 6)
                window.bold { window.addch(?F) }
              end
            when :open_timeline_tab
              window.addstr('[ ] Show tweets')
              window.setpos(current_line, 6)
              window.bold { window.addch(?t) }
            when :open_website
              window.addstr('[ ] Open website')
              window.setpos(current_line, 6)
              window.bold { window.addch(?W) }
            end

            current_line += 2
          end
        end

        def user
          User.find(user_id)
        end
      end
    end
  end
end
