module Tab
  module Base
    include Curses

    attr_accessor :title

    def refresh
      object_id
      update if TabManager.instance.current_tab.object_id == object_id
    end

    private

    def update
      exit
      fail NotImplementedError, 'update method must be implemented'
    end
  end
end
