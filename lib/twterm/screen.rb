module Twterm
  class Screen
    include Singleton
    include Curses

    def initialize
      @screen = init_screen
      noecho
      cbreak
      curs_set(0)
      stdscr.keypad(true)
      start_color
      use_default_colors
    end

    def wait
      @thread = Thread.new do
        loop do
          scan
        end
      end
      @thread.join
    end

    def refresh
      TabManager.instance.refresh_window
      TabManager.instance.current_tab.refresh
      UserWindow.instance.refresh_window
      Notifier.instance.show
    end

    private

    def scan
      App.instance.reset_interruption_handler

      key = getch

      return if TabManager.instance.current_tab.respond_to_key(key)
      return if TabManager.instance.respond_to_key(key)

      case key
      when 'n'
        Tweetbox.instance.compose
        return
      when 'Q'
        App.instance.quit
      when '/'
        # filter
      else
      end
    end
  end
end
