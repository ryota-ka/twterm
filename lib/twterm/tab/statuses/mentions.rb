require 'twterm/tab/statuses/abstract_statuses_tab'
require 'twterm/event/status/mention'

module Twterm
  module Tab
    module Statuses
      class Mentions < AbstractStatusesTab
        include Subscriber

        def close
          fail NotClosableError
        end

        def fetch
          client.mentions
        end

        def initialize(app, client)
          fail ArgumentError, 'argument must be an instance of Client class' unless client.is_a? Client

          super(app, client)

          subscribe(Event::Status::Mention) { |e| prepend(e.status) }

          reload.then do |statuses|
            initially_loaded!
            statuses.each { |s| append(s) }
            scroller.move_to_top
          end

          @auto_reloader = Scheduler.new(300) { reload }
        end

        def title
          'Mentions'.freeze
        end
      end
    end
  end
end
