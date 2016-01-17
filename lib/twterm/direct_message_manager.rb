require 'twterm/client'
require 'twterm/direct_message'
require 'twterm/event/direct_message/fetched'
require 'twterm/publisher'
require 'twterm/scheduler'
require 'twterm/user'
require 'twterm/utils'

module Twterm
  class DirectMessageManager
    include Publisher, Utils

    def initialize(client)
      check_type Client, client

      @client = client
      @conversations = {}

      fetch

      Scheduler.new(300) { fetch }
    end

    def add(collocutor, message)
      check_type User, collocutor
      check_type DirectMessage, message

      @conversations[collocutor.id] ||= DirectMessage::Conversation.new(collocutor)
      @conversations[collocutor.id] << message
    end

    def fetch
      client.direct_messages_received.then do |messages|
        messages.each { |m| add(m.sender, m) }
        publish(Event::DirectMessage::Fetched.new)
      end

      client.direct_messages_sent.then do |messages|
        messages.each { |m| add(m.recipient, m) }
        publish(Event::DirectMessage::Fetched.new)
      end
    end

    def conversations
      @conversations.values
    end

    private

    attr_reader :client
  end
end
