module Tab
  module Base
    include Curses

    attr_accessor :title

    def refresh
      return if @refreshing || TabManager.instance.current_tab.object_id != object_id

      @refreshing = true
      Thread.new do
        update
        @refreshing = false
      end
    end

    def close
      @window.close
    end

    private

    def update
      fail NotImplementedError, 'update method must be implemented'
    end
  end
end
