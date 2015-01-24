require 'singleton'
require 'bundler'
Bundler.require

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
  end

  def wait
    @paused = false

    @thread = Thread.new do
      loop do
        scan unless @paused
      end
    end
    @thread.join
  end

  def stop
    @paused = true
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

    case getch
    when 'f'
      TabManager.instance.current_tab.favorite
    when 'g', Key::HOME
      TabManager.instance.current_tab.move_to_top
    when 'G', Key::END
      TabManager.instance.current_tab.move_to_bottom
    when 'h', 2
      TabManager.instance.previous
    when 'j', 14, Key::DOWN
      TabManager.instance.current_tab.move_down
    when 'k', 16, Key::UP
      TabManager.instance.current_tab.move_up
    when 'l', 6
      TabManager.instance.next
    when 'n'
      Tweetbox.instance.compose
      return
    when 'q'
      exit
    when 'r'
      TabManager.instance.current_tab.reply
    when 'R'
      TabManager.instance.current_tab.retweet
    when 'u'
      TabManager.instance.current_tab.show_user
    when 'w'
      TabManager.instance.close
    when 4
      TabManager.instance.current_tab.move_down(10)
    when 21
      TabManager.instance.current_tab.move_up(10)
    when '/'
      # filter
    else
    end
  end
end
