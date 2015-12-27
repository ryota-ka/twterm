require 'twterm/subscriber'
require 'twterm/event/status/timeline'
require 'twterm/utils'

module Twterm
  module Tab
    module Statuses
      class Home
        include Base
        include Subscriber
        include Utils

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
          check_type Client, client

          super()
          @client = client
          subscribe(Event::Status::Timeline) { |e| prepend e.status }

          fetch { scroller.move_to_top }
          @auto_reloader = Scheduler.new(180) { fetch }
        end

        def title
          'Home'.freeze
        end
      end
    end
  end
end
