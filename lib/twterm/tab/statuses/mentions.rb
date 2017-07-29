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
          client.mentions
        end

        def initialize(app, client)
          fail ArgumentError, 'argument must be an instance of Client class' unless client.is_a? Client

          super(app, client)

          subscribe(Event::Status::Mention) { |e| prepend(e.status) }

          fetch.then do |statuses|
            initially_loaded!
            statuses.each { |s| append(s) }
            scroller.move_to_top
          end

          @auto_reloader = Scheduler.new(300) { reload }
        end

        def reload
          fetch.then do |statuses|
            statuses.each { |s| append(s) }
            sort
          end
        end

        def title
          'Mentions'.freeze
        end
      end
    end
  end
end
