require_relative './abstract_key_mapper'

class Twterm::KeyMapper::StatusKeyMapper < Twterm::KeyMapper::AbstractKeyMapper
  def self.category
    'status'.freeze
  end

  def self.commands
    %i(
      compose
      conversation
      destroy
      like
      open_link
      reply
      retweet
      user
    )
  end
end
