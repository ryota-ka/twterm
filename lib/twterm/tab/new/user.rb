require 'twterm/publisher'

module Twterm
  module Tab
    module New
      class User
        include Base
        include Publisher
        include Readline

        def ==(other)
          other.is_a?(self.class)
        end

        def invoke_input
          resetter = proc do
            reset_prog_mode
            sleep 0.1
            Screen.instance.refresh
          end

          CompletionManager.instance.set_screen_name_mode!

          input_thread = Thread.new do
            close_screen
            puts "\nSearch user"
            screen_name = (readline('> @') || '').strip
            resetter.call

            if screen_name.nil? || screen_name.empty?
              TabManager.instance.switch(Tab::New::Start.new)
            else
              Client.current.show_user(screen_name).then do |user|
                if user.nil?
                  publish(Event::Notification.new(:error, 'User not found'))
                  tab = Tab::New::Start.new
                else
                  tab = Tab::UserTab.new(user.id)
                end
                TabManager.instance.switch(tab)
              end
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

        def respond_to_key(_)
          false
        end

        def title
          'New tab'.freeze
        end

        private

        def update; end
      end
    end
  end
end
