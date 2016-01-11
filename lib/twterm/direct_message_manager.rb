require 'twterm/client'
require 'twterm/direct_message'
require 'twterm/event/direct_message/fetched'
require 'twterm/publisher'
require 'twterm/scheduler'
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

    def fetch
      client.direct_messages.then do |messages|
        add_to_conversations(messages)
        publish(Event::DirectMessage::Fetched.new)
      end
    end

    def conversations
      @conversations.values
    end

    private

    attr_reader :client

    def add_to_conversations(messages)
      messages.each do |message|
        collocutor = message.sender.screen_name == client.screen_name ? message.receiver : message.sender
        @conversations[collocutor.id] ||= DirectMessage::Conversation.new(collocutor)
        @conversations[collocutor.id] << message
      end
    end
  end
end
