require 'twterm/direct_message'
require 'twterm/status'
require 'twterm/list'
require 'twterm/user'

module Twterm
  class SearchQuery
    attr_reader :query

    def initialize(query)
      @query = query
    end

    def ===(other)
      matches = -> x { x.downcase.include?(query.downcase) }

      case other
      when DirectMessage
        [
          other.text,
          other.sender.screen_name,
          other.sender.name
        ].any?(&matches)
      when DirectMessage::Conversation
        [
          other.collocutor.name,
          other.collocutor.screen_name,
          other.preview
        ].any?(&matches)
      when List
        [
          other.description,
          other.full_name,
        ].any?(&matches)
      when Status
        [
          other.text,
          other.user.screen_name,
          other.user.name
        ].any?(&matches)
      when String
        matches.call(other)
      when User
        [
          other.name,
          other.screen_name,
          other.description
        ].compact.any?(&matches)
      else false
      end
    end

    def self.empty
      new('')
    end

    def empty?
      query.empty?
    end

    def to_s
      query
    end
  end
end
