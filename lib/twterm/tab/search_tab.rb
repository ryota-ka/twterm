module Twterm
  module Tab
    class SearchTab
      include StatusesTab
      include Dumpable

      attr_reader :query

      def initialize(query)
        super()

        @query = query
        @title = "\"#{@query}\""

        fetch { move_to_top }
        @auto_reloader = Schedule.new(300) { fetch }
      end

      def fetch
        Client.current.search(@query) do |statuses|
          statuses.reverse.each { |status| prepend(status) }
          yield if block_given?
        end
      end

      def close
        @auto_reloader.kill if @auto_reloader
        super
      end

      def ==(other)
        other.is_a?(self.class) && query == other.query
      end

      def dump
        @query
      end
    end
  end
end
