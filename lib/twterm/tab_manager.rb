require 'twterm/event/screen/resize'
require 'twterm/publisher'
require 'twterm/subscriber'
require 'twterm/utils'
require 'twterm/view'

module Twterm
  class TabManager
    include Curses
    include Publisher
    include Subscriber
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
      current_tab.render
      refresh_window
      result
    end

    def close
      current_tab.close
      @tabs.delete_at(@index)
      @history.delete_if { |n| n == @index }
      @history = @history.map { |i| i > @index ? i - 1 : i }
      @index = @history.first
      current_tab.render
      refresh_window
    rescue Tab::NotClosableError
      publish(Event::Message::Warning.new('this tab cannot be closed'))
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

    def initialize(app, client)
      @app, @client = app, client

      @tabs = []
      @index = 0
      @history = []

      @window = stdscr.subwin(3, stdscr.maxx, 0, 0)

      subscribe(Event::Screen::Resize, :resize)
    end

    def open_my_profile
      current_user_id = client.user_id
      tab = Tab::UserTab.new(app, client, current_user_id)
      add_and_show(tab)
    end

    def open_new
      tab = Tab::New::Start.new(app, client)
      add_and_show(tab)
    end

    def recover_tabs
      unless File.exist? DUMPED_TABS_FILE
        tab = Tab::KeyAssignmentsCheatsheet.new(app, client)
        add(tab)
        return
      end

      data = YAML.load(File.read(DUMPED_TABS_FILE))
      data.each do |klass, title, arg|
        tab = klass.recover(app, client, title, arg)
        add(tab)
      end
    rescue StandardError
      publish(Event::Message::Error.new('Failed to recover tabs'))
    end

    def refresh_window
      @window.clear
      view.render
      @window.refresh
    end

    def view
      wss = Image.string('  ')
      pipe = Image.string('|')

      image = @tabs
        .map { |t| [t, Image.string(t.title)] }
        .map { |t, r| t.equal?(current_tab) ? !r : r }
        .reduce(pipe) { |acc, x| acc - wss - x - wss - pipe }

      View.new(@window, image).at(1, 1)
    end

    def respond_to_key(key)
      k = KeyMapper.instance

      case key
      when k[:tab, :'1st']
        show_nth_tab(0)
      when k[:tab, :'2nd']
        show_nth_tab(1)
      when k[:tab, :'3rd']
        show_nth_tab(2)
      when k[:tab, :'4th']
        show_nth_tab(3)
      when k[:tab, :'5th']
        show_nth_tab(4)
      when k[:tab, :'6th']
        show_nth_tab(5)
      when k[:tab, :'7th']
        show_nth_tab(6)
      when k[:tab, :'8th']
        show_nth_tab(7)
      when k[:tab, :'9th']
        show_nth_tab(8)
      when k[:tab, :last]
        show_nth_tab(@tabs.count - 1)
      when k[:general, :left], Curses::Key::LEFT
        show_previous
      when k[:general, :right], Curses::Key::RIGHT
        show_next
      when k[:app, :me]
        open_my_profile
      when k[:tab, :new]
        open_new
      when k[:tab, :close]
        close
      else
        return false
      end
      true
    end

    def show_next
      @index = (@index + 1) % @tabs.count
      current_tab.render
      refresh_window
    end

    def show_nth_tab(n)
      return unless n < @tabs.count

      @index = n
      current_tab.render
      refresh_window
    end

    def show_previous
      @index = (@index - 1) % @tabs.count
      current_tab.render
      refresh_window
    end

    def switch(tab)
      close
      add_and_show(tab)
    end

    private

    attr_reader :app, :client

    def resize(_event)
      @window.resize(3, stdscr.maxx)
      @window.move(0, 0)
    end
  end
end
