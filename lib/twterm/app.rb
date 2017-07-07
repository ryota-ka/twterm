require 'curses'

require 'twterm/event/screen/resize'
require 'twterm/repository/friendship_repository'
require 'twterm/repository/direct_message_repository'
require 'twterm/repository/list_repository'
require 'twterm/repository/status_repository'
require 'twterm/repository/user_repository'
require 'twterm/uri_opener'

module Twterm
  class App
    include Publisher
    include Singleton

    DATA_DIR = "#{ENV['HOME']}/.twterm".freeze

    def direct_message_repository
      @direct_messages_repository ||= Repository::DirectMessageRepository.new
    end

    def friendship_repository
      @friendship_repository ||= Repository::FriendshipRepository.new
    end

    def list_repository
      @list_repository ||= Repository::ListRepository.new
    end

    def run
      Dir.mkdir(DATA_DIR, 0700) unless File.directory?(DATA_DIR)

      Auth.authenticate_user(config) if config[:user_id].nil?

      KeyMapper.instance

      Screen.instance
      SearchQueryWindow.instance

      timeline = Tab::Statuses::Home.new(client)
      TabManager.instance.add_and_show(timeline)

      mentions_tab = Tab::Statuses::Mentions.new(client)

      TabManager.instance.add(mentions_tab)
      TabManager.instance.recover_tabs

      Screen.instance.refresh

      client.connect_user_stream

      reset_interruption_handler

      URIOpener.instance

      Scheduler.new(300) do
        status_repository.expire(3600)

        _ = status_repository.all.map(&:user)
        user_repository.expire(3600)
      end

      user_repository.before_create do |user|
        client_id = client.user_id

        if user.following?
          friendship_repository.follow(client_id, user.id)
        else
          friendship_repository.unfollow(client_id, user.id)
        end

        if user.follow_request_sent?
          friendship_repository.following_requested(client_id, user.id)
        else
          friendship_repository.following_not_requested(client_id, user.id)
        end
      end

      status_repository.before_create do |tweet|
        tweet.hashtags.each do |hashtag|
          History::Hashtag.instance.add(hashtag.text)
        end
      end

      Screen.instance.wait
      Screen.instance.refresh
    end

    def register_interruption_handler(&block)
      fail ArgumentError, 'no block given' unless block_given?
      Signal.trap(:INT) { block.call }
    end

    def reset_interruption_handler
      Signal.trap(:INT) { App.instance.quit }
    end

    def quit
      Curses.close_screen
      TabManager.instance.dump_tabs
      exit
    end

    def status_repository
      @status_repository ||= Repository::StatusRepository.new
    end

    def user_repository
      @user_repository ||= Repository::UserRepository.new
    end

    private

    def client
      @client ||= Client.new(
        config[:user_id].to_i,
        config[:screen_name],
        config[:access_token],
        config[:access_token_secret]
      )
    end

    def config
      @config ||= Config.new
    end
  end
end
