Thread.abort_on_exception = true

module Twterm
  class HashtagManager
    include Singleton

    attr_reader :tags

    HISTORY_FILE = "#{App::DATA_DIR}/hashtags"
    MAX_HISTORY_SIZE = 500

    def initialize
      unless File.exist?(HISTORY_FILE)
        @tags = []
        return
      end

      @tags = YAML.load(File.read(HISTORY_FILE)) || []
    end

    def add(hashtag)
      @tags.unshift(hashtag)
      @tags = @tags.uniq.take(MAX_HISTORY_SIZE)
      save
    end

    private

    def save
      File.open(HISTORY_FILE, 'w', 0600) do |f|
        f.write @tags.to_yaml
      end
    end
  end
end
