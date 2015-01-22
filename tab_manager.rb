class TabManager
  include Singleton
  include Curses

  def initialize
    @tabs = []
    @index = 0

    @window = stdscr.subwin(3, stdscr.maxx - 3, 0, 0)
  end

  def add(tab)
    fail ArgumentError, 'argument must be an instance of Tab::Base' unless tab.is_a? Tab::Base
    @tabs << tab
    refresh_window
  end

  def add_and_show(tab)
    add(tab)
    @index = @tabs.count - 1
    current_tab.refresh
    refresh_window
  end

  def current_tab
    @tabs[@index]
  end

  def next
    @index = (@index + 1) % @tabs.count
    current_tab.refresh
    refresh_window
  end

  def previous
    @index = (@index - 1) % @tabs.count
    current_tab.refresh
    refresh_window
  end

  def close
    current_tab.close
    @tabs.delete_at(@index)
    @index = @tabs.count - 1
    current_tab.refresh
    refresh_window
  rescue Tab::NotClosableError
    Notifier.instance.show_error 'This tab cannot be closed'
  end

  private

  def refresh_window
    @window.clear
    current_tab_id = current_tab.object_id

    @window.setpos(1, 1)
    @window.addstr('|  ')
    @tabs.each do |tab|
      if tab.object_id == current_tab_id
        @window.bold do
          @window.addstr(tab.title)
        end
      else
        @window.addstr(tab.title)
      end
      @window.addstr('  |  ')
    end

    @window.refresh
  end
end
