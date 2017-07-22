require 'twterm/tab/statuses/base'

module Twterm
  module Tab
    module Statuses
      class Mentions < Base
        include Subscriber

        def close
          fail NotClosableError
        end

        def fetch
          client.mentions.then do |statuses|
            statuses.reverse.each(&method(:prepend))
            sort
          end
        end

        def initialize(app, client)
          fail ArgumentError, 'argument must be an instance of Client class' unless client.is_a? Client

          super(app, client)

          subscribe(Event::Status::Mention) { |e| prepend(e.status) }

          fetch.then do
            initially_loaded!
            scroller.move_to_top
          end

          @auto_reloader = Scheduler.new(300) { fetch }
        end

        def title
          'Mentions'.freeze
        end
      end
    end
  end
end
