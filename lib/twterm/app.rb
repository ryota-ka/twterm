require 'curses'

require 'twterm/completion_manager'
require 'twterm/environment'
require 'twterm/event/screen/refresh'
require 'twterm/message_window'
require 'twterm/notification_dispatcher'
require 'twterm/persistable_configuration_proxy'
require 'twterm/preferences'
require 'twterm/photo_viewer'
require 'twterm/repository/friendship_repository'
require 'twterm/repository/hashtag_repository'
require 'twterm/repository/list_repository'
require 'twterm/repository/status_repository'
require 'twterm/repository/user_repository'
require 'twterm/tab_manager'
require 'twterm/tweetbox'
require 'twterm/uri_opener'

module Twterm
  class App
    include Publisher

    attr_reader :environment, :preferences, :screen

    # return [Twterm::MessageWindow]
    attr_reader :message_window

    # return [Twterm::SearchQueryWindow]
    attr_reader :search_query_window

    DATA_DIR = "#{ENV['HOME']}/.twterm".freeze

    def initialize
      @environment = Environment.new
      @preferences = Preferences.default
    end

    def load_preferences_from_file!
      @preferences = PersistableConfigurationProxy
        .load_from_file!(Preferences, "#{DATA_DIR}/preferences.toml")
    end

    def completion_manager
      @completion_manager ||= CompletionManager.new(self)
    end

    def friendship_repository
      @friendship_repository ||= Repository::FriendshipRepository.new
    end

    def hashtag_repository
      @hashtag_repository ||= Repository::HashtagRepository.new
    end

    def list_repository
      @list_repository ||= Repository::ListRepository.new
    end

    def run
      Dir.mkdir(DATA_DIR, 0700) unless File.directory?(DATA_DIR)

      Auth.authenticate_user(config) if config[:user_id].nil?

      load_preferences_from_file!

      KeyMapper.instance

      @screen = Screen.new(self, client)

      @search_query_window = SearchQueryWindow.new(screen.search_query_window_window)
      @message_window = MessageWindow.new(screen.message_window_window)

      @notification_dispatcher = NotificationDispatcher.new(preferences)
      @photo_viewer = PhotoViewer.new(preferences)

      timeline = Tab::Statuses::Home.new(self, client)
      tab_manager.add_and_show(timeline)

      mentions_tab = Tab::Statuses::Mentions.new(self, client)

      tab_manager.add(mentions_tab)
      tab_manager.recover_tabs

      publish(Event::Screen::Refresh.new)

      reset_interruption_handler

      Signal.trap(:WINCH) { on_resize }
      Scheduler.new(60) { on_resize }

      URIOpener.instance

      Scheduler.new(300) do
        status_repository.expire(3600)

        _ = status_repository.all.map { |status| user_repository.find(status.user_id) }
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
        user_repository.create(tweet.user)
      end

      status_repository.before_create do |tweet|
        tweet.hashtags.each do |hashtag|
          hashtag_repository.create(hashtag)
        end
      end

      screen.wait
      screen.refresh
    end

    def register_interruption_handler(&block)
      fail ArgumentError, 'no block given' unless block_given?
      Signal.trap(:INT) { block.call }
    end

    def reset_interruption_handler
      Signal.trap(:INT) { quit }
    end

    def quit
      Curses.close_screen
      tab_manager.dump_tabs
      exit
    end

    def status_repository
      @status_repository ||= Repository::StatusRepository.new
    end

    def tab_manager
      @tab_manager ||= TabManager.new(self, client, screen.tab_manager_window)
    end

    def tweetbox
      @tweetbox = Tweetbox.new(self, client)
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
        config[:access_token_secret],
        {
          friendship: friendship_repository,
          hashtag: hashtag_repository,
          list: list_repository,
          status: status_repository,
          user: user_repository,
        }
      )
    end

    def config
      @config ||= Config.new
    end

    def on_resize
      lines, cols = `stty size`.split(' ').map(&:to_i)

      Readline.set_screen_size(lines, cols)

      screen.resize(lines, cols) unless Curses.closed?
    end
  end
end
