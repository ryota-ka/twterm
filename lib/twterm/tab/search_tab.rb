module Twterm
  module Tab
    class SearchTab
      include StatusesTab
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
        Client.current.search(@query) do |statuses|
          statuses.reverse.each(&method(:prepend))
          yield if block_given?
        end
      end

      def initialize(query)
        super()

        @query = query
        @title = "\"#{@query}\""

        fetch { scroll_manager.move_to_top }
        @auto_reloader = Scheduler.new(300) { fetch }
      end
    end
  end
end
