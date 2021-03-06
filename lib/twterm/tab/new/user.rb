require 'twterm/event/message/error'
require 'twterm/event/screen/refresh'
require 'twterm/publisher'
require 'twterm/tab/abstract_tab'

module Twterm
  module Tab
    module New
      class User < AbstractTab
        include Publisher
        include Readline

        def ==(other)
          other.is_a?(self.class)
        end

        def invoke_input
          resetter = proc do
            Curses.reset_prog_mode
            sleep 0.1
            publish(Event::Screen::Refresh.new)
          end

          app.completion_manager.set_screen_name_mode!

          input_thread = Thread.new do
            Curses.close_screen
            puts "\nSearch user"
            screen_name = (readline('> @', true) || '').strip
            resetter.call

            if screen_name.nil? || screen_name.empty?
              app.tab_manager.switch(Tab::New::Index.new(app, client))
            else
              client.show_user(screen_name).then do |user|
                if user.nil?
                  publish(Event::Message::Error.new('User not found'))
                  tab = Tab::New::Index.new(app, client)
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
            tab = Tab::New::Index.new(app, client)
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
