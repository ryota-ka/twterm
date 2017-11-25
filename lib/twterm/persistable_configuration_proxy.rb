require 'toml'

module Twterm
  class PersistableConfigurationProxy
    # @param [Twterm::AbstractPersistableConfiguration] instance A configuration to persist
    # @param [String] filepath File path to persist the given configuration
    def initialize(instance, filepath)
      @instance = instance
      @filepath = filepath
    end

    def [](*args)
      instance.[](*args)
    end

    def []=(*args)
      instance.[]=(*args)
      persist!
    end

    def self.getc
      system('stty raw -echo')
      STDIN.getc
    ensure
      system('stty -raw echo')
    end

    # Loads a configuration file from and returns a proxy.
    # Falls back to the default value when the specified file does not exist.
    #
    # @param [Class] klass Must be a subclass of {Twterm::AbstractPersistableConfiguration}
    # @param [String] filepath File path to load configuration from
    # @return [Twterm::PersistableConfigurationProxy] a configuration proxy
    def self.load_from_file!(klass, filepath)
      config = TOML.load_file(filepath, symbolize_keys: true)
      new(klass.new(config), filepath).migrate!
    rescue Errno::ENOENT
      new(klass.default, filepath)
    rescue TOML::ParseError, TOML::ValueOverwriteError => e
      msg =
        case e
        when TOML::ParseError
          "Your configuration file could not be parsed"
        when TOML::ValueOverwriteError
          "`#{e.key}` is declared more than once"
        end

      warn <<-EOS
\e[1mCould not load the configuration file: #{filepath}\e[0m
(#{msg})

Falling back to the default key assignments

Check the syntax and edit the file manually,
or remove it and launch twterm again to restore

Press any key to continue
  EOS

      getc

      new(klass.default, filepath)
    end

    # @return [self]
    def migrate!
      instance.complete_missing_items!
      persist!

      self
    end

    private

    attr_reader :filepath, :instance

    def persist!
      hash = TOML.dump(instance.to_h).gsub("\n[", "\n\n[")
      File.open(filepath, 'w', 0644) { |f| f.write(hash) }
    end
  end
end
