#!/usr/bin/env ruby
# encoding: utf-8

require './auth'
require './config'
require './screen'
require './timeline'
require './tweetbox'
require './notifier'
require './status'
require './client_manager'
require './user'
require './extentions'
require 'bundler'
Bundler.require

begin
  Twterm::Auth.authenticate_user if Twterm::Config[:screen_name].nil?

  client = Client.create(Twterm::Config[:access_token], Twterm::Config[:access_token_secret])

  client.home.reverse.each do |status|
    Timeline.instance.push(status)
  end

  Notifier.instance.show_message ''

  client.stream(Timeline.instance)

  t = Thread.new do
    loop do
      Screen.instance.wait
    end
  end
  t.join
rescue Interrupt
  Curses.close_screen
  exit
rescue Twitter::Error::TooManyRequests
  puts 'API rate limit exceeded'
  exit
end
