require_relative './abstract_key_mapper'

class Twterm::KeyMapper::UserKeyMapper < Twterm::KeyMapper::AbstractKeyMapper
  def self.category
    'user'.freeze
  end

  def self.commands
    %i(
      direct_message
      follow
      my_profile
      timeline
      website
    ).freeze
  end
end
