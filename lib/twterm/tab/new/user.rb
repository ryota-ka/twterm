require 'twterm/publisher'
require 'twterm/tab/base'
require 'twterm/event/notification/error'

module Twterm
  module Tab
    module New
      class User < Base
        include Publisher
        include Readline

        def ==(other)
          other.is_a?(self.class)
        end

        def invoke_input
          resetter = proc do
            reset_prog_mode
            sleep 0.1
            app.screen.refresh
          end

          app.completion_manager.set_screen_name_mode!

          input_thread = Thread.new do
            close_screen
            puts "\nSearch user"
            screen_name = (readline('> @') || '').strip
            resetter.call

            if screen_name.nil? || screen_name.empty?
              app.tab_manager.switch(Tab::New::Start.new(app, client))
            else
              client.show_user(screen_name).then do |user|
                if user.nil?
                  publish(Event::Notification::Error.new('User not found'))
                  tab = Tab::New::Start.new(app, client)
                else
                  tab = Tab::UserTab.new(app, client, user.id)
                end
                app.tab_manager.switch(tab)
              end
            end
          end

          app.register_interruption_handler do
            input_thread.kill
            resetter.call
            tab = Tab::New::Start.new(app, client)
            app.tab_manager.switch(tab)
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

        def image
          Image.empty
        end
      end
    end
  end
end
