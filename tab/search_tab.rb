module Tab
  class SearchTab
    include StatusesTab

    def initialize(query)
      super()

      @query = query
      @title = "\"#{@query}\""

      fetch { move_to_top }
    end

    def fetch
      ClientManager.instance.current.search(@query) do |statuses|
        statuses.each { |status| push(status) }
        yield if block_given?
      end
    end
  end
end
