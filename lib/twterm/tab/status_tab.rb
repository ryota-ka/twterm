require 'addressable/uri'

require 'twterm/event/open_uri'
require 'twterm/hashtag'
require 'twterm/image'
require 'twterm/image_builder/user_name_image_builder'
require 'twterm/publisher'
require 'twterm/tab/abstract_tab'
require 'twterm/tab/dumpable'
require 'twterm/tab/loadable'
require 'twterm/tab/scrollable'

module Twterm
  module Tab
    class StatusTab < AbstractTab
      include Dumpable
      include Publisher
      include Tab::Scrollable

      def initialize(app, client, status_id)
        super(app, client)

        @status_id = status_id
      end

      def drawable_item_count
        (window.maxy - status.text.split_by_width(window.maxx - 4).count - 6).div(2)
      end

      def dump
        status_id
      end

      def image
        if status.nil?
          find_or_fetch_status(status_id).then { render }
          return Image.string('Loading...')
        end

        if user.nil?
          find_or_fetch_user(status.user_id).then { render }
          return Image.string('Loading...')
        end

        header = [
          ImageBuilder::UserNameImageBuilder.new(user).build,
          Image.string(status.date.to_s).brackets,
          (Image.whitespace.color(:black, :red) if status.favorited?),
          (Image.whitespace.color(:black, :green) if status.retweeted?),
          ((Image.number(status.favorite_count) - Image.plural(status.favorite_count, 'like')).color(:red) if status.favorite_count.positive?),
          ((Image.number(status.retweet_count) - Image.plural(status.retweet_count, 'RT')).color(:green) if status.retweet_count.positive?),
        ].compact.intersperse(Image.whitespace).reduce(Image.empty, :-)

        [
          header,
          Image.blank_line,
          *status.text.split_by_width(window.maxx - 4).map { |x| Image.string(x) },
          Image.blank_line,
          Image.blank_line,
          *drawable_items.flat_map.with_index do |item, i|
            curr = scroller.current_index?(i)
            Image.cursor(1, curr) - Image.whitespace - image_for_item(item).bold(curr)
          end.intersperse(Image.blank_line),
        ].reduce(Image.empty) { |acc, x| acc | x }
      end

      def items
        [
          :reply,
          :favorite,
          :retweet,
          :quote,
          (:destroy if user.id == client.user_id),
          :show_user,
          :open_in_browser,
          *status.media,
          *status.urls,
          *status.hashtags,
          *status.user_mentions,
        ].compact
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

      def title
        user.nil? ? 'Loading...' : "@#{user.screen_name}'s tweet"
      end

      private

      attr_reader :status_id

      def destroy!
        client
          .destroy_status(status)
          .then { app.tab_manager.close }
      end

      def favorite!
        if status.favorited?
          client.unfavorite(status).then { status.unfavorite! }
        else
          client.favorite(status).then { status.favorite! }
        end
          .then { render }
      end

      def highlight_with_entity(text, entity)
        starts, ends = entity.indices
        Image.string(text[0...starts]) - Image.string(text[starts...ends]).bold - Image.string(text[y...text.length])
      end

      # @return [Twterm::Image]
      def image_for_item(item)
        case item
        when :reply
          Image.string('Reply to this tweet')
        when :favorite
          Image.string(status.favorited? ? 'Unlike this tweet' : 'Like this tweet')
        when :retweet
          Image.string(status.retweeted? ? 'Unretweet this tweet' : 'Retweet this tweet')
        when :quote
          Image.string('Quote this tweet')
        when :destroy
          Image.string('Delete this tweet')
        when :show_user
          Image.string("Show user (@#{user.screen_name})")
        when :open_in_browser
          Image.string("Open this tweet in browser (#{status.url})")
        when Addressable::URI
          Image.string(item.to_s)
        when Hashtag
          Image.string("[Hashtag] ##{item.text}")
        when Twitter::Entity::UserMention
          Image.string("[User] #{item.name} (@#{item.screen_name})")
        when Twitter::Entity::URI
          Image.string("[URL] #{item.expanded_url}")
        when Twitter::Media::AnimatedGif
          url = item.video_info.variants.max { |v| v.bitrate }.url
          Image.string("[GIF] #{url}")
        when Twitter::Media::Photo
          Image.string("[Photo] #{item.media_url_https}")
        when Twitter::Media::Video
          url = item.video_info.variants.max { |v| v.bitrate }.url
          Image.string("[Video] #{url}")
        end
      end

      def perform_selected_action
        item = scroller.current_item

        case item
        when :reply
          reply!
        when :favorite
          favorite!
        when :retweet
          retweet!
        when :quote
          quote!
        when :destroy
          destroy!
        when :show_user
          show_user!
        when :open_in_browser
          publish(Event::OpenURI.new(status.url))
        when Hashtag
          tab = Tab::Statuses::Search.new(app, client, "##{item.text}")
          app.tab_manager.add_and_show(tab)
        when Twitter::Entity::UserMention
          tab = Tab::UserTab.new(app, client, item.id)
          app.tab_manager.add_and_show(tab)
        when Twitter::Entity::URI
          publish(Event::OpenURI.new(item.expanded_url))
        when Twitter::Media::Photo
          publish(Event::OpenURI.new(item.media_url_https))
        when Twitter::Media::AnimatedGif, Twitter::Media::Video
          url = item.video_info.variants.max { |v| v.bitrate }.url
          publish(Event::OpenURI.new(url))
        end
      end

      def quote!
        app.tweetbox.quote(status)
      end

      def reply!
        app.tweetbox.reply(status)
      end

      def retweet!
        if status.retweeted?
          client.unretweet(status).then { status.unretweet! }
        else
          client.retweet(status).then { status.retweet! }
        end
          .then { render }
      end

      def show_user!
        user_id = status.user_id
        user_tab = Tab::UserTab.new(app, client, user_id)
        app.tab_manager.add_and_show(user_tab)
      end

      def status
        app.status_repository.find(status_id)
      end

      def user
        status.nil? ? nil : app.user_repository.find(status.user_id)
      end
    end
  end
end
