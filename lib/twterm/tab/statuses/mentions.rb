module Twterm
  module Tab
    module Statuses
      class Mentions
        include Base
        include Subscriber

        def close
          fail NotClosableError
        end

        def fetch
          @client.mentions.then do |statuses|
            statuses.reverse.each(&method(:prepend))
            sort
            yield if block_given?
          end
        end

        def initialize(client)
          fail ArgumentError, 'argument must be an instance of Client class' unless client.is_a? Client

          super()

          @client = client

          subscribe(Event::Status::Mention) { |e| prepend(e.status) }

          fetch { scroller.move_to_top }
          @auto_reloader = Scheduler.new(300) { fetch }
        end

        def title
          'Mentions'.freeze
        end
      end
    end
  end
end
