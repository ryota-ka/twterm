#!/usr/bin/env ruby

require 'oauth'
require './auth'
require './config'
require './screen'
require './timeline'
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
require './tab/status_tab'
require './tab/timeline'
require './tab/mentions_tab'
require 'bundler'
Bundler.require

class App
  include Singleton

  def initialize
    Twterm::Auth.authenticate_user if Twterm::Config[:screen_name].nil?

    Screen.instance

    client = Client.create(Twterm::Config[:access_token], Twterm::Config[:access_token_secret])

    timeline = Tab::Timeline.new(client)
    timeline.connect_stream
    TabManager.instance.add(timeline)

    client.home.reverse.each do |status|
      TabManager.instance.current_tab.push(status)
    end
    TabManager.instance.current_tab.move_to_top

    mentions_tab = Tab::MentionsTab.new(client)
    Thread.new do
      mentions_tab.fetch
    end
    TabManager.instance.add(mentions_tab)

    Notifier.instance.show_message ''
    UserWindow.instance
  end

  def start
    t = Thread.new do
      loop do
        Screen.instance.wait
      end
    end
    t.join
  end

  def register_interruption_handler(&block)
    fail ArgumentError, 'Block must be passed' unless block_given?
    Signal.trap(:INT) do
      yield
    end
  end

  def reset_interruption_handler
    Signal.trap(:INT) do
      exit
    end
  end
end

App.instance.reset_interruption_handler
App.instance.start
