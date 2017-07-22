require 'concurrent'

require 'twterm/event/open_uri'
require 'twterm/event/status/delete'
require 'twterm/publisher'
require 'twterm/subscriber'
require 'twterm/tab/base'
require 'twterm/tab/loadable'
require 'twterm/utils'

module Twterm
  module Tab
    module Statuses
      class Base < Tab::Base
        include Publisher
        include Searchable
        include Subscriber
        include Loadable
        include Utils

        def append(status)
          check_type Status, status

          return if @status_ids.include?(status.id)

          @status_ids.unshift(status.id)
          status.split(window.maxx - 4)
          scroller.item_appended!
          render
        end

        def delete(status_id)
          app.status_repository.delete(status_id)
          render
        end

        def destroy_status
          status = highlighted_status

          client.destroy_status(status)
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
          client.method(method_name).call(highlighted_status)
            .then { render }
        end

        def fetch
          fail NotImplementedError, 'fetch method must be implemented'
        end

        def initialize(app, client)
          super(app, client)

          @status_ids = Concurrent::Array.new

          subscribe(Event::Status::Delete) { |e| delete(e.status_id) }
        end

        def items
          statuses.reverse
        end

        def matches?(status, query)
          user = app.user_repository.find(status.user_id)

          [
            status.text,
            user.screen_name,
            user.name
          ].any? { |x| x.downcase.include?(query.downcase) }
        end

        def open_link
          return if highlighted_status.nil?

          status = highlighted_status
          urls = status.urls.map(&:expanded_url) + status.media.map(&:expanded_url)
          urls
            .uniq
            .map { |url| Event::OpenURI.new(url) }
            .each { |e| publish(e) }
        end

        def prepend(status)
          fail unless status.is_a? Status

          return if @status_ids.include?(status.id)

          @status_ids << status.id
          status.split(window.maxx - 4)
          scroller.item_prepended!
          render
        end

        def reply
          return if highlighted_status.nil?
          app.tweetbox.compose(highlighted_status)
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
          else
            return false
          end
          true
        end

        def retweet
          return if highlighted_status.nil?
          client.retweet(highlighted_status).then { render }
        end

        def show_conversation
          return if highlighted_status.nil?
          tab = Tab::Statuses::Conversation.new(app, client, highlighted_status.id)
          app.tab_manager.add_and_show(tab)
        end

        def show_user
          return if highlighted_status.nil?
          user_id = highlighted_status.user_id
          user_tab = Tab::UserTab.new(app, client, user_id)
          app.tab_manager.add_and_show(user_tab)
        end

        def statuses
          statuses = @status_ids.map { |id| app.status_repository.find(id) }.compact
          @status_ids = statuses.map(&:id)

          statuses
        end

        def total_item_count
          search_query.empty? ? @status_ids.count : statuses.count
        end

        private

        def highlighted_status
          statuses[scroller.count - scroller.index - 1]
        end

        def image
          return Image.string(initially_loaded? ? 'No results found' : 'Loading...') if items.empty?

          scroller.drawable_items.map.with_index(0) do |status, i|
            user = app.user_repository.find(status.user_id)
            retweeted_by = app.user_repository.find(status.retweeted_by_user_id)

            header = [
              !Image.string(user.name).color(user.color),
              Image.string("@#{user.screen_name}").parens,
              Image.string(status.date.to_s).brackets,
              (Image.whitespace.color(:black, :red) if status.favorited?),
              (Image.whitespace.color(:black, :green) if status.retweeted?),
              ((Image.string('retweeted by ') - !Image.string("@#{retweeted_by.screen_name}")).parens unless status.retweeted_by_user_id.nil?),
              ((Image.number(status.favorite_count) - Image.plural(status.favorite_count, 'like')).color(:red) if status.favorite_count.positive?),
              ((Image.number(status.retweet_count) - Image.plural(status.retweet_count, 'RT')).color(:green) if status.retweet_count.positive?),
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
          repo = app.status_repository
          @status_ids &= repo.ids
          @status_ids.sort_by! { |id| repo.find(id).appeared_at }
        end
      end
    end
  end
end
