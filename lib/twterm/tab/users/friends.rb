require 'twterm/tab/users/abstract_users_tab'

module Twterm
  module Tab
    module Users
      class Friends < AbstractUsersTab
        include Dumpable

        attr_reader :user_id

        def dump
          user_id
        end

        def fetch
          client.friends(user_id) do |users|
            @user_ids.concat(users.map(&:id)).uniq!
            render
          end
        end

        def initialize(app, client, user_id)
          super(app, client)

          @user_id = user_id

          fetch.then do
            initially_loaded!
            move_to_top
          end
        end

        def title
          user.nil? ? 'Loading...' : "@#{user.screen_name} following"
        end

        private

        def user
          app.user_repository.find(user_id)
        end
      end
    end
  end
end
