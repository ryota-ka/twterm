require 'twterm/tab/statuses/base'

module Twterm
  module Tab
    module Statuses
      class Favorites < Base
        include Dumpable

        attr_reader :user, :user_id

        def ==(other)
          other.is_a?(self.class) && user_id == other.user_id
        end

        def dump
          @user.id
        end

        def fetch
          client.favorites(@user.id)
        end

        def initialize(app, client, user_id)
          super(app, client)

          @user_id = user_id

          find_or_fetch_user(user_id).then do |user|
            @user = user
            app.tab_manager.refresh_window

            reload.then do
              initially_loaded!
              scroller.move_to_top
            end
          end
        end

        def title
          @user.nil? ? 'Loading...' : "@#{@user.screen_name} likes"
        end
      end
    end
  end
end
