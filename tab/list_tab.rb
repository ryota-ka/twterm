module Tab
  class ListTab
    include StatusesTab

    attr_reader :list

    def initialize(list)
      fail ArgumentError, 'argument must be an instance of List class' unless list.is_a? List

      super()

      @list = list
      @title = @list.full_name
      fetch { move_to_top }
      auto_reload(300) { fetch }
    end

    def fetch
      client = ClientManager.instance.current
      client.list(@list) do |statuses|
        statuses.reverse.each do |status|
          push(status)
        end
        sort
        yield if block_given?
      end
    end

    def ==(other)
      return false unless other.is_a? Tab::ListTab
      list == other.list
    end
  end
end
