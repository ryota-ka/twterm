module Tab
  class MentionsTab
    include StatusTab

    def initialize(client)
      fail unless client.is_a? Client

      super()
      @client = client
    end

    def fetch
      @client.mentions.reverse.each do |status|
        self.push(status)
      end
    end

    def connect_stream
      @client.stream(self)
    end
  end
end
