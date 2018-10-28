require 'twterm/rest_client'

module Twterm
  class Client
    include RESTClient

    attr_reader :user_id, :screen_name

    def initialize(user_id, screen_name, access_token, access_token_secret, repositories)
      @user_id, @screen_name = user_id, screen_name
      @access_token, @access_token_secret = access_token, access_token_secret

      @friendship_repository = repositories[:friendship]
      @hashtag_repository = repositories[:hashtag]
      @list_repository = repositories[:list]
      @status_repository = repositories[:status]
      @user_repository = repositories[:user]

      @callbacks = {}

      @mute_filter = -> _ { true }
      fetch_muted_users do |muted_user_ids|
        @mute_filter = lambda do |status|
          !muted_user_ids.include?(status.user.id) &&
            !(status.retweeted_status.is_a?(Twitter::NullObject) &&
            muted_user_ids.include?(status.retweeted_status.user.id))
        end
      end
    end

    private

    attr_reader :friendship_repository, :hashtag_repository, :list_repository, :status_repository, :user_repository
  end
end
