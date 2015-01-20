class TabManager
  include Singleton

  def initialize
    @tabs = []
    @index = 0
  end

  def add(tab)
    fail ArgumentError, 'argument must be an instance of Tab::Base' unless tab.is_a? Tab::Base
    @tabs << tab
  end

  def current_tab
    @tabs[@index]
  end

  def next
    @index = (@index + 1) % @tabs.count
    current_tab.refresh_window
  end

  def previous
    @index = (@index - 1) % @tabs.count
    current_tab.refresh_window
  end
end
