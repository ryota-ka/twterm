#!/usr/bin/env ruby

require 'oauth'
require './auth'
require './config'
require './screen'
require './tweetbox'
require './notifier'
require './status'
require './client_manager'
require './user'
require './user_window'
require './extentions'
require './color_manager'
require './tab_manager'
require './tab/base'
require './tab/exceptions'
require './tab/statuses_tab'
require './tab/timeline_tab'
require './tab/mentions_tab'
require './tab/user_tab'
require './notification/base'
require './notification/message'
require './notification/error'
require 'bundler'
Bundler.require

class App
  include Singleton

  def initialize
    Auth.authenticate_user if Config[:screen_name].nil?

    Screen.instance

    client = Client.create(Config[:user_id], Config[:screen_name], Config[:access_token], Config[:access_token_secret])

    timeline = Tab::TimelineTab.new(client)
    TabManager.instance.add_and_show(timeline)

    mentions_tab = Tab::MentionsTab.new(client)
    TabManager.instance.add(mentions_tab)

    Screen.instance.refresh

    client.stream
    UserWindow.instance

    reset_interruption_handler
  end

  def run
    Screen.instance.wait
    Screen.instance.refresh
  end

  def register_interruption_handler(&block)
    fail ArgumentError, 'no block given' unless block_given?
    Signal.trap(:INT) do
      block.call
    end
  end

  def reset_interruption_handler
    Signal.trap(:INT) do
      exit
    end
  end
end

App.instance.run
