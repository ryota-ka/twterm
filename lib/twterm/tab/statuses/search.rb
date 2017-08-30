require 'twterm/tab/statuses/base'

module Twterm
  module Tab
    module Statuses
      class Search < Base
        include Dumpable

        attr_reader :query

        def ==(other)
          other.is_a?(self.class) && query == other.query
        end

        def close
          @auto_reloader.kill if @auto_reloader
          super
        end

        def dump
          @query
        end

        def fetch
          client.search(@query)
        end

        def initialize(app, client, query)
          super(app, client)

          @query = query
          @title = "\"#{@query}\""

          reload.then do
            initially_loaded!
            scroller.move_to_top
          end

          @auto_reloader = Scheduler.new(300) { reload }
        end
      end
    end
  end
end
