module Tab
  class MentionsTab
    include StatusesTab

    def initialize(client)
      fail ArgumentError, 'argument must be an instance of Client class' unless client.is_a? Client

      super()
      @client = client
    end

    def fetch
      Thread.new do
        @client.mentions.reverse.each do |status|
          push(status)
        end
      end
    end
  end
end
