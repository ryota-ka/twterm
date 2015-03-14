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
      client = Client.current
      client.list(@list) do |statuses|
        statuses.reverse.each(&method(:prepend))
        sort
        yield if block_given?
      end
    end

    def ==(other)
      other.is_a?(self.class) && list == other.list
    end
  end
end
