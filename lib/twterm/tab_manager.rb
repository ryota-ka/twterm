require 'twterm/utils'

module Twterm
  class TabManager
    include Singleton
    include Curses
    include Utils

    DUMPED_TABS_FILE = "#{ENV['HOME']}/.twterm/dumped_tabs"

    def add(tab_to_add)
      check_type Tab::Base, tab_to_add

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

    def current_tab
      @history.unshift(@index).uniq!
      @tabs[@index]
    end

    def dump_tabs
      data = @tabs.each_with_object([]) do |tab, arr|
        next unless tab.is_a? Tab::Dumpable
        arr << [tab.class, tab.title, tab.dump]
      end
      File.open(DUMPED_TABS_FILE, 'w', 0600) do |f|
        f.write data.to_yaml
      end
    end

    def each_tab(&block)
      @tabs.each do |tab|
        block.call(tab)
      end
    end

    def initialize
      @tabs = []
      @index = 0
      @history = []

      @window = stdscr.subwin(3, stdscr.maxx, 0, 0)
    end

    def open_my_profile
      current_user_id = Client.current.user_id
      tab = Tab::UserTab.new(current_user_id)
      add_and_show(tab)
    end

    def open_new
      tab = Tab::New::Start.new
      add_and_show(tab)
    end

    def recover_tabs
      unless File.exist? DUMPED_TABS_FILE
        tab = Tab::KeyAssignmentsCheatsheet.new
        add(tab)
        return
      end

      data = YAML.load(File.read(DUMPED_TABS_FILE))
      data.each do |klass, title, arg|
        tab = klass.recover(title, arg)
        add(tab)
      end
    rescue
      Notifier.instance.show_error 'Failed to recover tabs'
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

    def resize
      @window.resize(3, stdscr.maxx)
      @window.move(0, 0)
    end

    def respond_to_key(key)
      case key
      when ?1..?9
        @index = key.to_i - 1 if @tabs.count >= key.to_i
        current_tab.refresh
        refresh_window
      when ?0
        @index = @tabs.count - 1
        current_tab.refresh
        refresh_window
      when ?h, 2, Key::LEFT
        show_previous
      when ?l, 6, Key::RIGHT
        show_next
      when ?P
        open_my_profile
      when ?N
        open_new
      when ?w
        close
      else
        return false
      end
      true
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

    def switch(tab)
      close
      add_and_show(tab)
    end
  end
end
