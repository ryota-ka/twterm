require 'readline'
require 'singleton'
require 'bundler'
Bundler.require

class Tweetbox
  include Singleton
  include Readline
  include Curses

  def initialize
    @status = ''
  end

  def compose(in_reply_to = nil)
    if in_reply_to.is_a? Status
      @in_reply_to = in_reply_to
    else
      @in_reply_to = nil
    end

    thread = Thread.new do
      close_screen
      puts "\ncompose new tweet:"
      @status = readline(@in_reply_to.nil? ? '> ' : " @#{in_reply_to.user.screen_name} ", true)
      reset_prog_mode
      post
      Screen.instance.refresh
    end

    App.instance.register_interruption_handler do
      thread.kill
      clear
      puts "\ncanceled"
      reset_prog_mode
      Screen.instance.refresh
    end

    thread.join
  end

  def post
    return if @status.nil?

    ClientManager.instance.current.post(@status, @in_reply_to)
    clear
    Screen.instance.refresh
    Screen.instance.wait
  end

  def clear
    @status = ''
  end
end
