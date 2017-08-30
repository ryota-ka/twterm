require 'twterm/subscriber'
require 'twterm/event/status/timeline'
require 'twterm/tab/statuses/base'
require 'twterm/utils'

module Twterm
  module Tab
    module Statuses
      class Home < Base
        include Subscriber
        include Utils

        def close
          fail NotClosableError
        end

        def fetch
          client.home_timeline
        end

        def initialize(app, client)
          super(app, client)

          subscribe(Event::Status::Timeline) { |e| prepend(e.status) }

          reload.then do
            initially_loaded!
            scroller.move_to_top
          end

          @auto_reloader = Scheduler.new(180) { reload }
        end

        def title
          'Home'.freeze
        end
      end
    end
  end
end
