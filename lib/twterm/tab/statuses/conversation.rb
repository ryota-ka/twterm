require 'concurrent'

require 'twterm/tab/statuses/base'

module Twterm
  module Tab
    module Statuses
      class Conversation < Base
        include Dumpable

        attr_reader :status_id

        def ==(other)
          other.is_a?(self.class) && status_id == other.status_id
        end

        def fetch
          find_or_fetch_status(status_id).then do |status|
            append(status)
            fetch_ancestor(status)
            fetch_quoted_status(status)
            find_descendants(status)
            fetch_possible_quotes(status)
            fetch_possible_replies(status)
          end
        end

        def fetch_ancestor(status)
          in_reply_to_status_id = status.in_reply_to_status_id

          if in_reply_to_status_id.nil?
            Concurrent::Promise.fulfill(nil)
          elsif (instance = app.status_repository.find(in_reply_to_status_id))
            Concurrent::Promise.fulfill(instance)
          else
            client.show_status(in_reply_to_status_id)
          end
            .then do |in_reply_to|
              next if in_reply_to.nil?
              append(in_reply_to)
              sort
              fetch_ancestor(in_reply_to)
            end
        end

        def fetch_possible_quotes(status)
          client.search(status.url).then do |statuses|
            statuses
              .select { |s| !s.retweet? && s.quoted_status_id == status.id }
              .each { |s| prepend(s) }

            sort
            render
          end
        end

        def fetch_possible_replies(status)
          user = app.user_repository.find(status.user_id)

          return if user.nil?

          client.search("to:#{user.screen_name}").then do |statuses|
            statuses
              .select { |s| !s.retweet? && s.in_reply_to_status_id == status.id }
              .each { |s| prepend(s) }

            sort
            render
          end
        end

        def fetch_quoted_status(status)
          quoted_status_id = status.quoted_status_id

          if quoted_status_id.nil?
            Concurrent::Promise.fulfill(nil)
          elsif (instance = app.status_repository.find(quoted_status_id))
            Concurrent::Promise.fulfill(instance)
          else
            client.show_status(quoted_status_id)
          end
            .then do |quoted_status|
              next if quoted_status.nil?
              append(quoted_status)
              sort
              fetch_ancestor(quoted_status)
              fetch_quoted_status(quoted_status)
            end
        end

        def find_descendants(status)
          app.status_repository.find_replies_for(status.id).reject { |s| s.retweet? }.each do |reply|
            prepend(reply)
            find_descendants(reply)
          end

          app.status_repository.find_quotes_for(status.id).reject { |s| s.retweet? }.each do |quote|
            prepend(quote)
            find_descendants(quote)
          end

          sort
        end

        def dump
          @status_id
        end

        def initialize(app, client, status_id)
          super(app, client)

          @status_id = status_id

          reload.then do
            scroller.move_to_top
            sort
          end
        end

        def title
          'Conversation'.freeze
        end
      end
    end
  end
end
