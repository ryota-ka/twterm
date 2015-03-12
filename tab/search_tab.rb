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
      ClientManager.instance.current.search(@query) do |statuses|
        statuses.reverse.each { |status| prepend(status) }
        yield if block_given?
      end
    end

    def ==(other)
      return false unless other.is_a? Tab::SearchTab
      query == other.query
    end
  end
end
