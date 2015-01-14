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
    App.instance.reset_interruption_handler

    case getch
    when 'f'
      Timeline.instance.favorite
    when 'g', Key::HOME
      Timeline.instance.move_to_top
    when 'G', Key::END
      Timeline.instance.move_to_bottom
    when 'j', 14, Key::DOWN
      Timeline.instance.move_down
    when 'k', 16, Key::UP
      Timeline.instance.move_up
    when 'n'
      Notifier.instance.show_message 'Compose new tweet'
      Tweetbox.instance.compose
      return
    when 'q'
      exit
    when 'r'
      Timeline.instance.reply
    when 'R'
      Timeline.instance.retweet
    when 'u'
      # show user
    when 4
      Timeline.instance.move_down(10)
    when 21
      Timeline.instance.move_up(10)
    when '/'
      # filter
    else
    end
  end
end
