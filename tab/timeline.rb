module Tab
  class Timeline
    include StatusTab

    def initialize(client)
      fail unless client.is_a? Client

      super()
      @client = client
    end

    def connect_stream
      @client.stream(self)
    end
  end
end
