module Twterm
  module Tab
    class TimelineTab
      include StatusesTab

      def close
        fail NotClosableError
      end

      def fetch
        @client.home_timeline do |statuses|
          statuses.each(&method(:prepend))
          sort
          yield if block_given?
        end
      end

      def initialize(client)
        fail ArgumentError, 'argument must be an instance of Client class' unless client.is_a? Client

        super()
        @client = client
        @client.on_timeline_status(&method(:prepend))
        @title = 'Timeline'

        fetch { scroll_manager.move_to_top }
        @auto_reloader = Scheduler.new(180) { fetch }
      end
    end
  end
end
