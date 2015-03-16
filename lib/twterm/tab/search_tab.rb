module Twterm
  module Tab
    class SearchTab
      include StatusesTab

      attr_reader :query

      def initialize(query)
        super()

        @query = query
        @title = "\"#{@query}\""

        fetch { move_to_top }
      end

      def fetch
        Client.current.search(@query) do |statuses|
          statuses.reverse.each { |status| prepend(status) }
          yield if block_given?
        end
      end

      def ==(other)
        other.is_a?(self.class) && query == other.query
      end
    end
  end
end
