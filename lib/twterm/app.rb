require 'curses'
require 'twterm/event/screen/resize'
require 'twterm/uri_opener'

module Twterm
  class App
    include Publisher
    include Singleton

    DATA_DIR = "#{ENV['HOME']}/.twterm"

    def initialize
      Dir.mkdir(DATA_DIR, 0700) unless File.directory?(DATA_DIR)

      Auth.authenticate_user(config) if config[:user_id].nil?

      Screen.instance
      FilterQueryWindow.instance

      timeline = Tab::Statuses::Home.new(client)
      TabManager.instance.add_and_show(timeline)

      mentions_tab = Tab::Statuses::Mentions.new(client)
      TabManager.instance.add(mentions_tab)
      TabManager.instance.recover_tabs

      Screen.instance.refresh

      client.connect_user_stream

      reset_interruption_handler

      URIOpener.instance

      resize = proc do
        break if Curses.closed?

        lines = `tput lines`.to_i
        cols = `tput cols`.to_i
        publish(Event::Screen::Resize.new(lines, cols))
      end

      Signal.trap(:WINCH, &resize)
      Scheduler.new(60, &resize)
    end

    def run
      run_periodic_cleanup

      Screen.instance.wait
      Screen.instance.refresh
    end

    def register_interruption_handler(&block)
      fail ArgumentError, 'no block given' unless block_given?
      Signal.trap(:INT) { block.call }
    end

    def reset_interruption_handler
      Signal.trap(:INT) { App.instance.quit }
    end

    def quit
      Curses.close_screen
      TabManager.instance.dump_tabs
      exit
    end

    private

    def client
      @client ||= Client.new(
        config[:user_id].to_i,
        config[:screen_name],
        config[:access_token],
        config[:access_token_secret]
      )
    end

    def config
      @config ||= Config.new
    end

    def run_periodic_cleanup
      Scheduler.new(300) do
        Status.cleanup
        User.cleanup
      end
    end
  end
end
