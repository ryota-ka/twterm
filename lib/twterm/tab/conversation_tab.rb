module Twterm
  module Tab
    class ConversationTab
      include StatusesTab
      include Dumpable

      attr_reader :status

      def initialize(status_id)
        @title = 'Conversation'
        super()

        Status.find_or_fetch(status_id) do |status|
          @status = status

          append(status)
          move_to_top
          Thread.new { fetch_in_reply_to_status(status) }
          Thread.new { fetch_replies(status) }
        end
      end

      def fetch_in_reply_to_status(status)
        status.in_reply_to_status do |in_reply_to|
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

      def ==(other)
        other.is_a?(self.class) && status == other.status
      end

      def dump
        @status.id
      end
    end
  end
end
