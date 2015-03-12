module Tab
  class ConversationTab
    include StatusesTab

    attr_reader :status

    def initialize(status)
      fail ArgumentError, 'argument must be an instance of Status class' unless status.is_a? Status

      @title = 'Conversation'

      super()
      prepend(status)
      Thread.new { fetch_reply(status) }
    end

    def fetch_reply(status)
      status.in_reply_to_status do |reply|
        return if reply.nil?
        append(reply)
        fetch_reply(reply)
      end
    end

    def ==(other)
      return false unless other.is_a? Tab::ConversationTab
      status == other.status
    end
  end
end
