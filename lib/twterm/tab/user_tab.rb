require 'twterm/event/open_uri'
require 'twterm/publisher'
require 'twterm/tab/base'
require 'twterm/tab/user_list_management'

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
        render
      end

      def initialize(user_id)
        super()

        self.title = 'Loading...'.freeze
        @user_id = user_id

        User.find_or_fetch(user_id).then do |user|
          render

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
          manage_lists
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

        k = KeyMapper.instance

        case key
        when 10
          perform_selected_action
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
          render

          user = users.first
          publish(Event::Notification::Success.new('Blocked @%s' % user.screen_name))
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
          render

          user = users.first
          if user.protected?
            msg = "Sent following request to @#{user.screen_name}"
          else
            msg = "Followed @#{user.screen_name}"
          end
          publish(Event::Notification::Success.new(msg))
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
          render

          user = users.first
          publish(Event::Notification::Success.new('Muted @%s' % user.screen_name))
        end
      end

      def muting?
        user.muted_by?(Client.current.user_id)
      end

      def myself?
        user_id == Client.current.user_id
      end

      def open_list_management_tab
        tab = Tab::UserListManagement.new(user_id)
        TabManager.instance.add_and_show(tab)
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
        when :manage_lists
          open_list_management_tab
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
          render

          user = users.first
          publish(Event::Notification::Success.new('Unblocked @%s' % user.screen_name))
        end
      end

      def unfollow
        Client.current.unfollow(user_id).then do |users|
          render

          user = users.first
          publish(Event::Notification::Success.new('Unfollowed @%s' % user.screen_name))
        end
      end

      def unmute
        Client.current.unmute(user_id).then do |users|
          render

          user = users.first
          publish(Event::Notification::Success.new('Unmuted @%s' % user.screen_name))
        end
      end

      def image
        if user.nil?
          User.find_or_fetch(user_id).then { render }
          return Image.empty
        end

        name = !Image.string(user.name) - Image.whitespace - Image.string("@#{user.screen_name}").parens

        badges = [
          (Image.string('protected').brackets.color(:yellow) if user.protected?),
          (Image.string('verified').brackets.color(:cyan) if user.verified?),
        ].compact.intersperse(Image.whitespace).reduce(Image.empty, :-)

        status =
          if myself?
            Image.string('your account').brackets.color(:yellow)
          else
            [
              ['following', :green, following?],
              ['not following', :white, !following? && !blocking? && !following_requested?],
              ['following requested', :yellow, following_requested?],
              ['follows you', :cyan, followed?],
              ['muting', :red, muting?],
              ['blocking', :red, blocking?],
            ]
              .select { |_, _, p| p }
              .map { |s, c, _| Image.string(s).brackets.color(c) }
              .intersperse(Image.whitespace)
              .reduce(Image.empty, :-)
          end

        description = user.description.split_by_width(window.maxx - 4)
          .map(&Image.method(:string))
          .reduce(Image.empty, :|)

        location = Image.string("Location: #{user.location}")

        foo = drawable_items.map.with_index(0) do |item, i|
          Image.cursor(1, scroller.current_index?(i)) - Image.whitespace -
            case item
            when :compose_direct_message
              Image.string('Compose direct message')
            when :toggle_block
              if blocking?
                Image.string('Unblock this user')
              else
                Image.string('Block this user')
              end
            when :toggle_follow
              if following?
                Image.string('Unfollow this user')
              elsif following_requested?
                Image.string('Following request sent')
              else
                Image.string('Follow this user')
              end
            when :toggle_mute
              if muting?
                Image.string('Unmute this user')
              else
                Image.string('Mute this user')
              end
            when :open_timeline_tab
              Image.number(user.statuses_count) - Image.whitespace - Image.plural(user.statuses_count, 'tweet')
            when :open_website
              Image.string("Open website (#{user.website})")
            when :show_likes
              Image.number(user.favorites_count) - Image.whitespace - Image.plural(user.favorites_count, 'like')
            when :show_followers
              Image.number(user.followers_count) - Image.whitespace - Image.plural(user.followers_count, 'follower')
            when :show_friends
              Image.number(user.friends_count) - Image.whitespace - Image.string('following')
            when :manage_lists
              Image.string('Add to / Remove from lists')
            end
        end
          .intersperse(Image.blank_line)
          .reduce(Image.empty, :|)

        [name, badges, status, description, location, foo]
          .compact
          .intersperse(Image.blank_line)
          .reduce(Image.empty, :|)
      end

      def user
        User.find(user_id)
      end
    end
  end
end
