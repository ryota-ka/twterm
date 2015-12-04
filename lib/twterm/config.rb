module Twterm
  class Config
    def [](key)
      config[key]
    end

    def []=(key, value)
      return if config[key] == value

      config[key] = value
      save_config_to_file
    end

    private

    def config
      @config ||= exist_config_file? ? load_config_file : {}
    end

    def save_config_to_file
      File.open(config_file_path, 'w', 0600) do |f|
        f.write config.to_yaml
      end
    end

    def load_config_file
      YAML.load_file(config_file_path)
    end

    def exist_config_file?
      File.exist?(config_file_path)
    end

    def config_file_path
      "#{App::DATA_DIR}/config".freeze
    end
  end
end
