require 'twterm/event/open_photo'
require 'twterm/event/open_uri'
require 'twterm/image_builder/user_name_image_builder'
require 'twterm/publisher'
require 'twterm/tab/abstract_tab'
require 'twterm/tab/user_list_management'

module Twterm
  module Tab
    class UserTab < AbstractTab
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

      def initialize(app, client, user_id)
        super(app, client)

        self.title = 'Loading...'.freeze
        @user_id = user_id

        find_or_fetch_user(user_id).then do |user|
          render

          client.lookup_friendships.then { render } unless app.friendship_repository.already_looked_up?(user_id)
          self.title = "@#{user.screen_name}"
        end
      end

      def items
        items = [
          :open_timeline_tab,
          :show_friends,
          :show_followers,
          :show_likes,
          :profile_image,
          (:profile_background_image unless user.profile_background_image.nil?),
          :manage_lists,
          (:compose_direct_message unless myself?),
          (:open_website unless user.website.nil?),
          (:toggle_follow unless myself?),
          (:toggle_mute unless myself?),
          (:toggle_block unless myself?),
          :open_in_browser,
        ].compact

        items
      end

      def respond_to_key(key)
        return true if scroller.respond_to_key(key)

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
        client.block(user_id).then do |users|
          render

          user = users.first
          publish(Event::Message::Success.new('Blocked @%s' % user.screen_name))
        end
      end

      def blocking?
        app.friendship_repository.blocking?(client.user_id, user_id)
      end

      def compose_direct_message
        app.direct_message_composer.compose(user)
      end

      def follow
        client.follow(user_id).then do |users|
          render

          user = users.first
          if user.protected?
            msg = "Sent following request to @#{user.screen_name}"
          else
            msg = "Followed @#{user.screen_name}"
          end
          publish(Event::Message::Success.new(msg))
        end
      end

      def followed?
        app.friendship_repository.following?(user_id, client.user_id)
      end

      def following?
        app.friendship_repository.following?(client.user_id, user_id)
      end

      def following_requested?
        app.friendship_repository.following_requested?(client.user_id, user_id)
      end

      def mute
        client.mute(user_id).then do |users|
          render

          user = users.first
          publish(Event::Message::Success.new('Muted @%s' % user.screen_name))
        end
      end

      def muting?
        app.friendship_repository.muting?(client.user_id, user_id)
      end

      def myself?
        user_id == client.user_id
      end

      def open_in_browser
        event = Event::OpenURI.new(user.url)
        publish(event)
      end

      def open_list_management_tab
        tab = Tab::UserListManagement.new(app, client, user_id)
        app.tab_manager.add_and_show(tab)
      end

      def open_profile_background_image
        event = Event::OpenPhoto.new(user.profile_background_image)
        publish(event)
      end

      def open_profile_image
        event = Event::OpenPhoto.new(user.profile_image)
        publish(event)
      end

      def open_timeline_tab
        tab = Tab::Statuses::UserTimeline.new(app, client, user_id)
        app.tab_manager.add_and_show(tab)
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
        when :open_in_browser
          open_in_browser
        when :open_timeline_tab
          open_timeline_tab
        when :open_website
          open_website
        when :profile_background_image
          open_profile_background_image
        when :profile_image
          open_profile_image
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
        tab = Tab::Statuses::Favorites.new(app, client, user_id)
        app.tab_manager.add_and_show(tab)
      end

      def show_followers
        tab = Tab::Users::Followers.new(app, client, user_id)
        app.tab_manager.add_and_show(tab)
      end

      def show_friends
        tab = Tab::Users::Friends.new(app, client, user_id)
        app.tab_manager.add_and_show(tab)
      end

      def unblock
        client.unblock(user_id).then do |users|
          render

          user = users.first
          publish(Event::Message::Success.new('Unblocked @%s' % user.screen_name))
        end
      end

      def unfollow
        client.unfollow(user_id).then do |users|
          render

          user = users.first
          publish(Event::Message::Success.new('Unfollowed @%s' % user.screen_name))
        end
      end

      def unmute
        client.unmute(user_id).then do |users|
          render

          user = users.first
          publish(Event::Message::Success.new('Unmuted @%s' % user.screen_name))
        end
      end

      def image
        if user.nil?
          find_or_fetch_user(user_id).then { render }
          return Image.empty
        end

        name = ImageBuilder::UserNameImageBuilder.new(user).build

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

        actions = drawable_items.map.with_index(0) do |item, i|
          curr = scroller.current_index?(i)
          Image.cursor(1, curr) - Image.whitespace -
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
            when :open_in_browser
              Image.string("Open this user in browser (#{user.url})")
            when :open_timeline_tab
              Image.number(user.statuses_count) - Image.whitespace - Image.plural(user.statuses_count, 'tweet')
            when :open_website
              Image.string("Open website (#{user.website})")
            when :profile_background_image
              Image.string('View profile background image')
            when :profile_image
              Image.string('View profile image')
            when :show_likes
              Image.number(user.favorites_count) - Image.whitespace - Image.plural(user.favorites_count, 'like')
            when :show_followers
              Image.number(user.followers_count) - Image.whitespace - Image.plural(user.followers_count, 'follower')
            when :show_friends
              Image.number(user.friends_count) - Image.whitespace - Image.string('following')
            when :manage_lists
              Image.string('Add to / Remove from lists')
            end
              .bold(curr)
        end
          .intersperse(Image.blank_line)
          .reduce(Image.empty, :|)

        [name, badges, status, description, location, Image.blank_line | actions]
          .compact
          .intersperse(Image.blank_line)
          .reduce(Image.empty, :|)
      end

      def user
        app.user_repository.find(user_id)
      end
    end
  end
end
