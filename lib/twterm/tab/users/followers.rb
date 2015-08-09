module Twterm
  module Tab
    module Users
      class Followers
        include Base
        include Dumpable

        attr_reader :user_id

        def dump
          user_id
        end

        def fetch
          Client.current.followers(user_id) do |users|
            @user_ids.concat(users.map(&:id)).uniq!
            refresh
          end
        end

        def initialize(user_id)
          super()

          @user_id = user_id

          fetch { move_to_top }
        end

        def title
          user.nil? ? 'Loading...' : "@#{user.screen_name} followers"
        end

        private

        def user
          User.find(user_id)
        end
      end
    end
  end
end
