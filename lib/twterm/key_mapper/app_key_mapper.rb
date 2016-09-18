require_relative './abstract_key_mapper'

class Twterm::KeyMapper::AppKeyMapper < Twterm::KeyMapper::AbstractKeyMapper
  def self.category
    'app'.freeze
  end

  def self.commands
    %i(
      cheatsheet
      quit
    ).freeze
  end
end
