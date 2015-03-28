module Twterm
  module Config
    CONFIG_FILE = "#{App::DATA_DIR}/config"

    def [](key)
      @config[key]
    end

    def []=(key, value)
      @config[key] = value
      save
    end

    def load
      unless File.exist? CONFIG_FILE
        @config = {}
        return
      end
      @config = YAML.load(File.read(CONFIG_FILE)) || {}
    end

    private

    def save
      File.open(CONFIG_FILE, 'w', 0600) do |f|
        f.write @config.to_yaml
      end
    end

    module_function :[], :[]=, :load, :save
  end
end
