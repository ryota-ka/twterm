require 'twterm/event/screen/resize'
require 'twterm/key_mapper'
require 'twterm/subscriber'

module Twterm
  class Screen
    include Subscriber
    include Curses

    def initialize(app, client)
      @app, @client = app, client

      @screen = init_screen
      noecho
      raw
      curs_set(0)
      stdscr.keypad(true)
      start_color
      use_default_colors

      subscribe(Event::Screen::Resize, :resize)
    end

    def refresh
      app.tab_manager.refresh_window
      app.tab_manager.current_tab.render
      MessageWindow.instance.show
    end

    def respond_to_key(key)
      k = KeyMapper.instance

      case key
      when k[:status, :compose]
        app.tweetbox.compose
        return
      when k[:app, :quit], 3
        app.quit
      when k[:app, :cheatsheet]
        tab = Tab::KeyAssignmentsCheatsheet.new(app, client)
        app.tab_manager.add_and_show tab
      else
        return false
      end

      true
    end

    def wait
      @thread = Thread.new do
        loop { scan }
      end
      @thread.join
    end

    private

    attr_reader :app, :client

    def resize(event)
      return if closed?

      lines, cols = event.lines, event.cols
      resizeterm(lines, cols)
      @screen.resize(lines, cols)

      refresh
    end

    def scan
      app.reset_interruption_handler

      key = getch

      return if app.tab_manager.current_tab.respond_to_key(key)
      return if app.tab_manager.respond_to_key(key)
      respond_to_key(key)
    end
  end
end
