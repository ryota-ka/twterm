require 'twterm/tab/statuses/base'

module Twterm
  module Tab
    module Statuses
      class UserTimeline < Base
        include Dumpable

        attr_reader :user, :user_id

        def ==(other)
          other.is_a?(self.class) && user_id == other.user_id
        end

        def close
          @auto_reloader.kill if @auto_reloader
          super
        end

        def dump
          @user.id
        end

        def fetch
          client.user_timeline(@user.id)
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

            @auto_reloader = Scheduler.new(120) { reload }
          end
        end

        def title
          @user.nil? ? 'Loading...' : "@#{@user.screen_name} timeline"
        end
      end
    end
  end
end
