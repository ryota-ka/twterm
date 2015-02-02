module Tab
  class ConversationTab
    include StatusesTab

    attr_reader :status

    def initialize(status)
      fail ArgumentError, 'argument must be an instance of Status class' unless status.is_a? Status

      @title = 'Conversation'

      super()
      push(status)
      Thread.new { fetch_reply(status) }
    end

    def fetch_reply(status)
      ClientManager.instance.current.show_status(status.in_reply_to_status_id) do |reply|
        unshift(reply)
        fetch_reply(reply)
      end unless status.in_reply_to_status_id.nil?
    end

    def ==(other)
      return false unless other.is_a? Tab::ConversationTab
      status == other.status
    end
  end
end
