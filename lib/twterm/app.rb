module Twterm
  class App
    include Singleton

    DATA_DIR = "#{ENV['HOME']}/.twterm"

    def initialize
      Dir.mkdir(DATA_DIR, 0700) unless File.directory?(DATA_DIR)

      Auth.authenticate_user(config) if config[:screen_name].nil?

      Screen.instance
      FilterQueryWindow.instance

      timeline = Tab::Statuses::Home.new(client)
      TabManager.instance.add_and_show(timeline)

      mentions_tab = Tab::Statuses::Mentions.new(client)
      TabManager.instance.add(mentions_tab)
      TabManager.instance.recover_tabs

      Screen.instance.refresh

      client.user_stream

      reset_interruption_handler

      Signal.trap(:WINCH) { Screen.instance.resize }
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
