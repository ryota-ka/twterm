require 'twterm/subscriber'
require 'twterm/tab/statuses/abstract_statuses_tab'
require 'twterm/utils'

module Twterm
  module Tab
    module Statuses
      class Home < AbstractStatusesTab
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
