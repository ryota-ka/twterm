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
          Client.current.user_timeline(@user.id).then do |statuses|
            statuses.reverse.each(&method(:prepend))
            sort
          end
        end

        def initialize(user_id)
          super()

          @user_id = user_id

          User.find_or_fetch(user_id).then do |user|
            @user = user
            TabManager.instance.refresh_window

            fetch.then do
              initially_loaded!
              scroller.move_to_top
            end

            @auto_reloader = Scheduler.new(120) { fetch }
          end
        end

        def title
          @user.nil? ? 'Loading...' : "@#{@user.screen_name} timeline"
        end
      end
    end
  end
end
