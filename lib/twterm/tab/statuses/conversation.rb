require 'concurrent'

require 'twterm/tab/statuses/base'

module Twterm
  module Tab
    module Statuses
      class Conversation < Base
        include Dumpable

        attr_reader :status_id

        def ==(other)
          other.is_a?(self.class) && status == other.status
        end

        def fetch
          find_or_fetch_status(status_id).then do |status|
            append(status)
            fetch_ancestor(status)
            find_descendants(status)
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

        def find_descendants(status)
          app.status_repository.find_replies_for(status.id).each do |reply|
            prepend(reply)
            find_descendants(reply)
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
