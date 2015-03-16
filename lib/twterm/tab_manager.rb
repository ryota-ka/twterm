module Twterm
  class TabManager
    include Singleton
    include Curses

    def initialize
      @tabs = []
      @index = 0
      @history = []

      @window = stdscr.subwin(3, stdscr.maxx - 30, 0, 0)
    end

    def add(tab_to_add)
      fail ArgumentError, 'argument must be an instance of Tab::Base' unless tab_to_add.is_a? Tab::Base
      @tabs.each.with_index do |tab, i|
        next unless tab == tab_to_add
        @index = i
        refresh_window
        return false
      end
      @tabs << tab_to_add
      @history.push(@tabs.count)
      refresh_window
      true
    end

    def add_and_show(tab)
      result = add(tab)
      @index = @tabs.count - 1 if result
      current_tab.refresh
      refresh_window
      result
    end

    def current_tab
      @history.unshift(@index).uniq!
      @tabs[@index]
    end

    def show_next
      @index = (@index + 1) % @tabs.count
      current_tab.refresh
      refresh_window
    end

    def show_previous
      @index = (@index - 1) % @tabs.count
      current_tab.refresh
      refresh_window
    end

    def open_new
      tab = Tab::New::Start.new
      add_and_show(tab)
    end

    def close
      current_tab.close
      @tabs.delete_at(@index)
      @history.delete_if { |n| n == @index }
      @history = @history.map { |i| i > @index ? i - 1 : i }
      @index = @history.first
      current_tab.refresh
      refresh_window
    rescue Tab::NotClosableError
      Notifier.instance.show_error 'This tab cannot be closed'
    end

    def switch(tab)
      close
      add_and_show(tab)
    end

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

    def respond_to_key(key)
      case key
      when 'h', 2, Key::LEFT
        show_previous
      when 'l', 6, Key::RIGHT
        show_next
      when 'N'
        open_new
      when 'w'
        close
      else
        return false
      end
      true
    end
  end
end
