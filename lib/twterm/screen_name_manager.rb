Thread.abort_on_exception = true

module Twterm
  class ScreenNameManager
    include Singleton

    attr_reader :screen_names

    HISTORY_FILE = "#{App::DATA_DIR}/screen_names"
    MAX_HISTORY_SIZE = 500

    def initialize
      unless File.exist?(HISTORY_FILE)
        @screen_names = []
        return
      end

      @screen_names = YAML.load(File.read(HISTORY_FILE)) || []
    end

    def add(screen_name)
      @screen_names.unshift(screen_name)
      @screen_names = @screen_names.uniq.take(MAX_HISTORY_SIZE)
      save
    end

    private

    def save
      File.open(HISTORY_FILE, 'w', 0600) do |f|
        f.write @screen_names.to_yaml
      end
    end
  end
end
