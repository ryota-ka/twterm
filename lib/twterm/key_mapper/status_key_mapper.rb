require_relative './abstract_key_mapper'

class Twterm::KeyMapper::StatusKeyMapper < Twterm::KeyMapper::AbstractKeyMapper
  DEFAULT_MAPPINGS = {
    compose: '^N',
    conversation: 'c',
    destroy: 'D',
    like: 'L',
    open_link: 'o',
    reply: 'r',
    retweet: 'R',
    user: 'U',
  }.freeze

  def self.category
    'status'.freeze
  end
end
