module Tab
  class TimelineTab
    include StatusesTab

    def initialize(client)
      fail ArgumentError, 'argument must be an instance of Client class' unless client.is_a? Client

      super()
      @client = client

      @title = 'Timeline'
    end

    def connect_stream
      @client.stream(self)
    end

    def close
      fail NotClosableError
    end
  end
end
