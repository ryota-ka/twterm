require 'toml'

require 'twterm/abstract_persistable_configuration'

module Twterm
  class Preferences < AbstractPersistableConfiguration
    def initialize(preferences)
      super(preferences)
    end

    # @param [Symbol] cat
    # @param [Symbol] key
    def [](cat, key)
      validate_key!(cat, key)

      configuration[cat][key]
    end

    def []=(cat, key, value)
      validate_key!(cat, key)

      configuration[cat][key] = value
    end

    # Returns an instance having the default value
    #
    # @return [Twterm::Preferences] an instance having the default value
    def self.default
      new({
        notification_backend: {
          inline: true,
          terminal_notifier: false,
          tmux: false,
        },
      })
    end

    # @return [Hash]
    def to_h
      configuration
    end

    # @return [Hash]
    def self.structure
      bool = -> x { x == true || x == false }

      {
        notification_backend: {
          inline: bool,
          terminal_notifier: bool,
          tmux: bool,
        },
      }
    end

    private

    alias_method :preferences, :configuration

    # @raise [ArgumentError]
    def validate_key!(cat, key)
      raise ArgumentError, "no such category: #{cat}" unless configuration.has_key?(cat)
      raise ArgumentError, "no such key: #{cat}.#{key}" unless configuration[cat].has_key?(key)
    end
  end
end
