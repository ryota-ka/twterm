module Tab
  class MentionsTab
    include StatusesTab

    def initialize(client)
      fail ArgumentError, 'argument must be an instance of Client class' unless client.is_a? Client

      super()

      @client = client
      @client.on_mention do |status|
        push(status)
        Notifier.instance.show_message 'You have a new mention'
      end

      @title = 'Mentions'

      fetch { move_to_top }
    end

    def fetch
      @client.mentions do |statuses|
        statuses.reverse.each do |status|
          push(status)
        end
        yield if block_given?
      end
    end

    def close
      fail NotClosableError
    end
  end
end
