require 'twterm/tab/users/base'

module Twterm
  module Tab
    module Users
      class Friends < Base
        include Dumpable

        attr_reader :user_id

        def dump
          user_id
        end

        def fetch
          Client.current.friends(user_id) do |users|
            @user_ids.concat(users.map(&:id)).uniq!
            render
          end
        end

        def initialize(user_id)
          super()

          @user_id = user_id

          fetch { move_to_top }
        end

        def title
          user.nil? ? 'Loading...' : "@#{user.screen_name} following"
        end

        private

        def user
          User.find(user_id)
        end
      end
    end
  end
end
