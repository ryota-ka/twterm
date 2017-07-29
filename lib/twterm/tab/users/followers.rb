require 'twterm/tab/users/base'

module Twterm
  module Tab
    module Users
      class Followers < Base
        include Dumpable

        attr_reader :user_id

        def dump
          user_id
        end

        def fetch
          client.followers(user_id) do |users|
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
          user.nil? ? 'Loading...' : "@#{user.screen_name} followers"
        end

        private

        def user
          app.user_repository.find(user_id)
        end
      end
    end
  end
end
