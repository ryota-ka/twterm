module Tab
  class TimelineTab
    include StatusesTab

    def initialize(client)
      fail ArgumentError, 'argument must be an instance of Client class' unless client.is_a? Client

      super()
      @client = client
      @client.on_timeline_status(&method(:prepend))
      @title = 'Timeline'

      fetch { move_to_top }
      auto_reload(180) { fetch }
    end

    def fetch
      Thread.new do
        @client.home_timeline do |statuses|
          statuses.each(&method(:prepend))
          sort
          yield if block_given?
        end
      end
    end

    def close
      fail NotClosableError
    end
  end
end
