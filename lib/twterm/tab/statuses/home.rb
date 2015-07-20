module Twterm
  module Tab
    module Statuses
      class Home
        include Base

        def close
          fail NotClosableError
        end

        def fetch
          @client.home_timeline.then do |statuses|
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
          @title = 'Home'

          fetch { scroller.move_to_top }
          @auto_reloader = Scheduler.new(180) { fetch }
        end
      end
    end
  end
end
