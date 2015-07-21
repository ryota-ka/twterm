module Twterm
  module Tab
    module Statuses
      class Conversation
        include Base
        include Dumpable

        attr_reader :status

        def ==(other)
          other.is_a?(self.class) && status == other.status
        end

        def fetch_in_reply_to_status(status)
          status.in_reply_to_status.then do |in_reply_to|
            return if in_reply_to.nil?
            append(in_reply_to)
            sort
            Thread.new { fetch_in_reply_to_status(in_reply_to) }
          end
        end

        def fetch_replies(status)
          status.replies.each do |reply|
            prepend(reply)
            sort
            Thread.new { fetch_replies(reply) }
          end
        end

        def dump
          @status.id
        end

        def initialize(status_id)
          super()

          Status.find_or_fetch(status_id).then do |status|
            @status = status

            append(status)
            scroller.move_to_top
            Thread.new { fetch_in_reply_to_status(status) }
            Thread.new { fetch_replies(status) }
          end
        end

        def title
          'Conversation'.freeze
        end
      end
    end
  end
end
