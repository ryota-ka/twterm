module Twterm
  module History
    module Base
      MAX_HISTORY_SIZE = 500

      attr_reader :history

      def initialize
        unless File.exist?(history_file)
          @history = []
          return
        end

        begin
          @history = YAML.load(File.read(history_file)) || []
        rescue
          @history = []
        end
      end

      def add(hashtag)
        @history.unshift(hashtag)
        @history = @history.uniq.take(MAX_HISTORY_SIZE)
        save
      end

      private

      def save
        File.open(history_file, 'w', 0600) do |f|
          f.write @history.to_yaml
        end
      end

      def history_file
        fail NotImplementedError, 'history_file method must be implemented'
      end
    end
  end
end
