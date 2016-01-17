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
          Client.current.search(@query).then do |statuses|
            statuses.reverse.each(&method(:prepend))
            yield if block_given?
          end
        end

        def initialize(query)
          super()

          @query = query
          @title = "\"#{@query}\""

          fetch { scroller.move_to_top }
          @auto_reloader = Scheduler.new(300) { fetch }
        end
      end
    end
  end
end
