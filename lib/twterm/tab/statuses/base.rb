require 'twterm/event/open_uri'
require 'twterm/event/status/delete'
require 'twterm/publisher'
require 'twterm/subscriber'
require 'twterm/tab/base'
require 'twterm/utils'

module Twterm
  module Tab
    module Statuses
      class Base < Tab::Base
        include FilterableList
        include Publisher
        include Scrollable
        include Subscriber
        include Utils

        def append(status)
          check_type Status, status

          return if @status_ids.include?(status.id)

          @status_ids.unshift(status.id)
          status.split(window.maxx - 4)
          status.touch!
          scroller.item_appended!
          render
        end

        def delete(status_id)
          Status.delete(status_id)
          render
        end

        def destroy_status
          status = highlighted_status

          Client.current.destroy_status(status)
        end

        def drawable_item_count
          statuses.reverse.drop(scroller.offset).lazy
          .map { |s| s.split(window.maxx - 4).count + 2 }
          .scan(0, :+)
          .each_cons(2)
          .select { |_, l| l < window.maxy }
          .count
        end

        def favorite
          return if highlighted_status.nil?

          method_name = highlighted_status.favorited ? :unfavorite : :favorite
          Client.current.method(method_name).call(highlighted_status)
            .then { render }
        end

        def fetch
          fail NotImplementedError, 'fetch method must be implemented'
        end

        def initialize
          super

          @status_ids = []

          subscribe(Event::Status::Delete) { |e| delete(e.status_id) }
        end

        def items
          statuses.reverse
        end

        def open_link
          return if highlighted_status.nil?

          status = highlighted_status
          urls = status.urls.map(&:expanded_url) + status.media.map(&:expanded_url)
          urls
            .map { |url| Event::OpenURI.new(url) }
            .each { |e| publish(e) }
        end

        def prepend(status)
          fail unless status.is_a? Status

          return if @status_ids.include?(status.id)

          @status_ids << status.id
          status.split(window.maxx - 4)
          status.touch!
          scroller.item_prepended!
          render
        end

        def reply
          return if highlighted_status.nil?
          Tweetbox.instance.compose(highlighted_status)
        end

        def respond_to_key(key)
          return true if scroller.respond_to_key(key)

          k = KeyMapper.instance

          case key
          when k[:status, :conversation]
            show_conversation
          when k[:status, :destroy]
            destroy_status
          when k[:status, :like]
            favorite
          when k[:status, :open_link]
            open_link
          when k[:status, :reply]
            reply
          when k[:status, :retweet]
            retweet
          when k[:tab, :reload]
            fetch
          when k[:status, :user]
            show_user
          when k[:tab, :filter]
            filter
          when k[:tab, :reset_filter]
            reset_filter
          else
            return false
          end
          true
        end

        def retweet
          return if highlighted_status.nil?
          Client.current.retweet(highlighted_status).then { render }
        end

        def show_conversation
          return if highlighted_status.nil?
          tab = Tab::Statuses::Conversation.new(highlighted_status.id)
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

          if filter_query.empty?
            statuses
          else
            statuses.select { |s| s.matches?(filter_query) }
          end
        end

        def touch_statuses
          statuses.reverse.take(100).each(&:touch!)
        end

        def total_item_count
          filter_query.empty? ? @status_ids.count : statuses.count
        end

        private

        def highlighted_status
          statuses[scroller.count - scroller.index - 1]
        end

        def image
          scroller.drawable_items.map.with_index(0) do |status, i|
            header = [
              !Image.string(status.user.name).color(status.user.color),
              Image.string("@#{status.user.screen_name}").parens,
              Image.string(status.date.to_s).brackets,
              (Image.whitespace.color(:black, :red) if status.favorited?),
              (Image.whitespace.color(:black, :green) if status.retweeted?),
              ((Image.string('retweeted by ') - !Image.string("@#{status.retweeted_by.screen_name}")).parens unless status.retweeted_by.nil?),
              (Image.string("#{status.favorite_count}like#{status.favorite_count > 1 ? 's' : ''}").color(:red) if status.favorite_count.positive?),
              (Image.string("#{status.retweet_count}RT#{status.retweet_count > 1 ? 's' : ''}").color(:green) if status.retweet_count.positive?),
            ].compact.intersperse(Image.whitespace).reduce(Image.empty, :-)

            body = status
              .split(window.maxx - 4)
              .map(&Image.method(:string))
              .reduce(Image.empty, :|)

            s = header | body

            Image.cursor(s.height, scroller.current_index?(i)) - Image.whitespace - s
          end
            .intersperse(Image.blank_line)
            .reduce(Image.empty, :|)
        end

        def sort
          @status_ids &= Status.all.map(&:id)
          @status_ids.sort_by! { |id| Status.find(id).appeared_at }
        end
      end
    end
  end
end
