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

  def add_and_show(tab)
    add(tab)
    @index = @tabs.count - 1
    current_tab.refresh
  end

  def current_tab
    @tabs[@index]
  end

  def next
    @index = (@index + 1) % @tabs.count
    current_tab.refresh
  end

  def previous
    @index = (@index - 1) % @tabs.count
    current_tab.refresh
  end

  def close
    current_tab.close
    @tabs.delete_at(@index)
    @index = @tabs.count - 1
    current_tab.refresh
  rescue Tab::NotClosableError
    Notifier.instance.show_error 'This tab cannot be closed'
  end
end
