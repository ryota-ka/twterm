module Twterm
  module Tab
    class UserTab
      include StatusesTab
      include Dumpable

      attr_reader :user

      def initialize(user_id)
        super()

        User.find_or_fetch(user_id) do |user|
          @user = user
          @title = "@#{@user.screen_name}"
          TabManager.instance.refresh_window

          fetch { move_to_top }
          @auto_reloader = Scheduler.new(120) { fetch }
        end
      end

      def fetch
        Client.current.user_timeline(@user.id) do |statuses|
          statuses.reverse.each(&method(:prepend))
          sort
          yield if block_given?
        end
      end

      def close
        @auto_reloader.kill if @auto_reloader
        super
      end

      def ==(other)
        other.is_a?(self.class) && user == other.user
      end

      def dump
        @user.id
      end
    end
  end
end
