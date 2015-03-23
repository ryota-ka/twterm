module Twterm
  module Tab
    module New
      class User
        include Base
        include Readline

        def initialize
          super

          @title = 'New tab'
          @window.refresh
        end

        def respond_to_key(_)
          false
        end

        def invoke_input
          resetter = proc do
            reset_prog_mode
            sleep 0.1
            Screen.instance.refresh
          end

          input_thread = Thread.new do
            close_screen
            puts "\nSearch user"
            screen_name = readline('> @').strip
            resetter.call

            Client.current.show_user(screen_name) do |user|
              if screen_name.nil? || screen_name.empty? || user.nil?
                Notifier.instance.show_error 'User not found' if user.nil?
                tab = Tab::New::Start.new
              else
                tab = Tab::UserTab.new(user)
              end

              TabManager.instance.switch(tab)
            end
          end

          App.instance.register_interruption_handler do
            input_thread.kill
            resetter.call
            tab = Tab::New::Start.new
            TabManager.instance.switch(tab)
          end

          input_thread.join
        end

        private

        def update; end
      end
    end
  end
end
