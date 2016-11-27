require 'twterm/event/open_uri'
require 'twterm/publisher'
require 'twterm/tab/base'

module Twterm
  module Tab
    class UserTab < Base
      include Dumpable
      include Publisher
      include Scrollable

      attr_reader :user_id

      def ==(other)
        other.is_a?(self.class) && user_id == other.user_id
      end

      def dump
        user_id
      end

      def drawable_item_count
        (window.maxy - 11 - bio_height).div(2)
      end

      def fetch
        update
      end

      def initialize(user_id)
        super()

        self.title = 'Loading...'.freeze
        @user_id = user_id

        User.find_or_fetch(user_id).then do |user|
          refresh

          Client.current.lookup_friendships.then { render } unless Friendship.already_looked_up?(user_id)
          self.title = "@#{user.screen_name}"
        end
      end

      def items
        items = %i(
          open_timeline_tab
          show_friends
          show_followers
          show_likes
        )
        items << :compose_direct_message unless myself?
        items << :open_website  unless user.website.nil?
        items << :toggle_follow unless myself?
        items << :toggle_mute   unless myself?
        items << :toggle_block  unless myself?

        items
      end

      def respond_to_key(key)
        return true if scroller.respond_to_key(key)

        case key
        when ?D
          compose_direct_message unless myself?
        when ?F
          follow unless myself?
        when 10
          perform_selected_action
        when ?t
          open_timeline_tab
        when ?W
          open_website
        else
          return false
        end

        true
      end

      private

      def bio_height
        320.div(window.maxx - 6) + 1
      end

      def block
        Client.current.block(user_id).then do |users|
          refresh

          user = users.first
          publish(Event::Notification.new(:message, 'Blocked @%s' % user.screen_name))
        end
      end

      def blocking?
        user.blocked_by?(Client.current.user_id)
      end

      def compose_direct_message
        DirectMessageComposer.instance.compose(user)
      end

      def follow
        Client.current.follow(user_id).then do |users|
          refresh

          user = users.first
          if user.protected?
            msg = "Sent following request to @#{user.screen_name}"
          else
            msg = "Followed @#{user.screen_name}"
          end
          publish(Event::Notification.new(:message, msg))
        end
      end

      def followed?
        user.following?(Client.current.user_id)
      end

      def following?
        user.followed_by?(Client.current.user_id)
      end

      def following_requested?
        user.following_requested_by?(Client.current.user_id)
      end

      def mute
        Client.current.mute(user_id).then do |users|
          refresh

          user = users.first
          publish(Event::Notification.new(:message, 'Muted @%s' % user.screen_name))
        end
      end

      def muting?
        user.muted_by?(Client.current.user_id)
      end

      def myself?
        user_id == Client.current.user_id
      end

      def open_timeline_tab
        tab = Tab::Statuses::UserTimeline.new(user_id)
        TabManager.instance.add_and_show(tab)
      end

      def open_website
        return if user.website.nil?

        publish(Event::OpenURI.new(user.website))
      end

      def perform_selected_action
        case scroller.current_item
        when :compose_direct_message
          compose_direct_message
        when :open_timeline_tab
          open_timeline_tab
        when :open_website
          open_website
        when :show_likes
          show_likes
        when :show_followers
          show_followers
        when :show_friends
          show_friends
        when :toggle_block
          blocking? ? unblock : block
        when :toggle_follow
          if following?
            unfollow
          elsif following_requested?
            # do nothing
          else
            follow
          end
        when :toggle_mute
          muting? ? unmute : mute
        end
      end

      def show_likes
        tab = Tab::Statuses::Favorites.new(user_id)
        TabManager.instance.add_and_show(tab)
      end

      def show_followers
        tab = Tab::Users::Followers.new(user_id)
        TabManager.instance.add_and_show(tab)
      end

      def show_friends
        tab = Tab::Users::Friends.new(user_id)
        TabManager.instance.add_and_show(tab)
      end

      def unblock
        Client.current.unblock(user_id).then do |users|
          refresh

          user = users.first
          publish(Event::Notification.new(:message, 'Unblocked @%s' % user.screen_name))
        end
      end

      def unfollow
        Client.current.unfollow(user_id).then do |users|
          refresh

          user = users.first
          publish(Event::Notification.new(:message, 'Unfollowed @%s' % user.screen_name))
        end
      end

      def unmute
        Client.current.unmute(user_id).then do |users|
          refresh

          user = users.first
          publish(Event::Notification.new(:message, 'Unmuted @%s' % user.screen_name))
        end
      end

      def update
        if user.nil?
          User.find_or_fetch(user_id).then { update }
          return
        end

        window.setpos(2, 3)
        window.bold { window.addstr(user.name) }
        window.addstr(" (@#{user.screen_name})")

        window.with_color(:yellow) { window.addstr(' [protected]') } if user.protected?
        window.with_color(:cyan) { window.addstr(' [verified]') } if user.verified?

        window.setpos(5, 4)
        if myself?
          window.with_color(:yellow) { window.addstr(' [your account]') }
        else
          window.with_color(:green) { window.addstr(' [following]') } if following?
          window.with_color(:white) { window.addstr(' [not following]') } if !following? && !blocking? && !following_requested?
          window.with_color(:yellow) { window.addstr(' [following requested]') } if following_requested?
          window.with_color(:cyan) { window.addstr(' [follows you]') } if followed?
          window.with_color(:red) { window.addstr(' [muting]') } if muting?
          window.with_color(:red) { window.addstr(' [blocking]') } if blocking?
        end

        user.description.split_by_width(window.maxx - 6).each.with_index(7) do |line, i|
          window.setpos(i, 5)
          window.addstr(line)
        end

        window.setpos(8 + bio_height, 5)
        window.addstr("Location: #{user.location}") unless user.location.nil?

        current_line = 11 + bio_height

        drawable_items.each.with_index(0) do |item, i|
          if scroller.current_item? i
            window.setpos(current_line, 3)
            window.with_color(:black, :magenta) { window.addch(' ') }
          end

          window.setpos(current_line, 5)
          case item
          when :compose_direct_message
            window.addstr('[ ] Compose direct message')
            window.setpos(current_line, 6)
            window.bold { window.addch(?D) }
          when :toggle_block
            if blocking?
              window.addstr('    Unblock this user')
            else
              window.addstr('    Block this user')
            end
          when :toggle_follow
            if following?
              window.addstr('    Unfollow this user')
            elsif following_requested?
              window.addstr('    Following request sent')
            else
              window.addstr('[ ] Follow this user')
              window.setpos(current_line, 6)
              window.bold { window.addch(?F) }
            end
          when :toggle_mute
            if muting?
              window.addstr('    Unmute this user')
            else
              window.addstr('    Mute this user')
            end
          when :open_timeline_tab
            window.addstr("[ ] #{user.statuses_count.format} tweets")
            window.setpos(current_line, 6)
            window.bold { window.addch(?t) }
          when :open_website
            window.addstr("[ ] Open website (#{user.website})")
            window.setpos(current_line, 6)
            window.bold { window.addch(?W) }
          when :show_likes
            window.addstr("    #{user.favorites_count.format} likes")
          when :show_followers
            window.addstr("    #{user.followers_count.format} followers")
          when :show_friends
            window.addstr("    #{user.friends_count.format} following")
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
