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

    resetter = proc do
      reset_prog_mode
      sleep 0.1
      Screen.instance.refresh
    end

    thread = Thread.new do
      close_screen
      puts "\ncompose new tweet:"
      @status = readline(@in_reply_to.nil? ? '> ' : " @#{in_reply_to.user.screen_name} ", true)
      resetter.call
      post
    end

    App.instance.register_interruption_handler do
      thread.kill
      clear
      puts "\ncanceled"
      resetter.call
    end

    thread.join
  end

  def post
    return if @status.nil?

    Client.current.post(@status, @in_reply_to)
    clear
  end

  def clear
    @status = ''
  end
end
