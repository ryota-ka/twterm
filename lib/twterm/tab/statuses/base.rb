require 'concurrent'

require 'twterm/event/open_uri'
require 'twterm/event/status/delete'
require 'twterm/event/status_garbage_collected'
require 'twterm/image_builder/user_name_image_builder'
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

          @status_ids.push(status.id)
          status.split(window.maxx - 4)
          scroller.item_appended!
          render
        end

        def delete(status_id)
          app.status_repository.delete(status_id)
          @status_ids.delete(status_id)
          render
        end

        def destroy_status
          status = highlighted_original_status

          client.destroy_status(status)
        end

        def drawable_item_count
          statuses.drop(scroller.offset).lazy
          .map { |s| s.split(window.maxx - 4).count + 2 }
          .scan(0, :+)
          .each_cons(2)
          .select { |_, l| l < window.maxy }
          .count
        end

        def favorite
          status = highlighted_original_status

          return if status.nil?

          if status.favorited?
            client.unfavorite(status)
              .then { status.unfavorite! }
          else
            client.favorite(status)
              .then { status.favorite! }
          end
            .then { render }
        end

        def fetch
          fail NotImplementedError, 'fetch method must be implemented'
        end

        def initialize(app, client)
          super(app, client)

          @status_ids = Concurrent::Array.new

          subscribe(Event::Status::Delete) { |e| delete(e.status_id) }
          subscribe(Event::StatusGarbageCollected) { |e| @status_ids.delete(e.id) }
        end

        def items
          statuses
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
          status = highlighted_original_status

          return if status.nil?

          urls = status.urls.map(&:expanded_url) + status.media.map(&:expanded_url)
          urls
            .uniq
            .map { |url| Event::OpenURI.new(url) }
            .each { |e| publish(e) }
        end

        def prepend(status)
          fail unless status.is_a? Status

          return if @status_ids.include?(status.id)

          @status_ids.unshift(status.id)
          status.split(window.maxx - 4)
          scroller.item_prepended!
          render
        end

        def quote
          return if highlighted_status.nil?

          app.tweetbox.quote(highlighted_original_status)
        end

        def reply
          return if highlighted_status.nil?

          app.tweetbox.reply(highlighted_original_status)
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
            reload
          when k[:status, :quote]
            quote
          when k[:status, :user]
            show_user
          else
            return false
          end
          true
        end

        def retweet
          status = highlighted_original_status

          return if status.nil?

          if status.retweeted?
            client.unretweet(status)
              .then { status.unretweet! }
          else
            client.retweet(status)
              .then { status.retweet! }
          end
            .then { render }
        end

        def show_conversation
          status = highlighted_original_status

          return if status.nil?

          tab = Tab::Statuses::Conversation.new(app, client, highlighted_original_status.id)
          app.tab_manager.add_and_show(tab)
        end

        def show_user
          status = highlighted_original_status

          return if status.nil?

          user_id = status.user_id
          user_tab = Tab::UserTab.new(app, client, user_id)
          app.tab_manager.add_and_show(user_tab)
        end

        def statuses
          @status_ids.map { |id| app.status_repository.find(id) }.compact
        end

        def total_item_count
          statuses.count
        end

        private

        def highlighted_original_status
          status = highlighted_status

          status.retweet? ? app.status_repository.find(status.retweeted_status_id) : status
        end

        def highlighted_status
          statuses[scroller.index]
        end

        def image
          return Image.string(initially_loaded? ? 'No results found' : 'Loading...') if items.empty?

          scroller.drawable_items.map.with_index(0) do |status, i|
            original = status.retweet? ? app.status_repository.find(status.retweeted_status_id) : status
            user = app.user_repository.find(original.user_id)
            retweeted_by = app.user_repository.find(status.user_id)

            header = [
              ImageBuilder::UserNameImageBuilder.new(user).build,
              Image.string(original.date.to_s).brackets,
              (Image.whitespace.color(:black, :red) if original.favorited?),
              (Image.whitespace.color(:black, :green) if original.retweeted?),
              ((Image.string('retweeted by ') - !Image.string("@#{retweeted_by.screen_name}")).parens if status.retweet?),
              ((Image.number(original.favorite_count) - Image.plural(original.favorite_count, 'like')).color(:red) if original.favorite_count.positive?),
              ((Image.number(original.retweet_count) - Image.plural(original.retweet_count, 'RT')).color(:green) if original.retweet_count.positive?),
            ].compact.intersperse(Image.whitespace).reduce(Image.empty, :-)

            body = original
              .split(window.maxx - 4)
              .map(&Image.method(:string))
              .reduce(Image.empty, :|)

            s = header | body

            Image.cursor(s.height, scroller.current_index?(i)) - Image.whitespace - s
          end
            .intersperse(Image.blank_line)
            .reduce(Image.empty, :|)
        end

        def reload
          fetch.then do |statuses|
            statuses.each { |s| append(s) }
            sort
          end
        end

        def sort
          return if items.empty? || scroller.current_item.nil?

          formerly_selected_status_id = scroller.current_item.id

          repo = app.status_repository

          @status_ids.sort_by! { |status_id| repo.find(status_id).created_at }.reverse!

          unless formerly_selected_status_id.nil?
            new_index = @status_ids.index(formerly_selected_status_id)
            scroller.move_to(new_index) unless new_index.nil?
          end

          self
        end
      end
    end
  end
end
