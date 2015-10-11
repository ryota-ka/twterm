module Twterm
  module History
    module Savable
      include Base

      def initialize
        unless File.exist?(file)
          @history = []
          return
        end

        begin
          @history = YAML.load(File.read(file)) || []
        rescue
          @history = []
        end

        Scheduler.new(300) { save }
      end

      def add(item)
        @history << item unless @history.include?(item)
        @history = history.take(1000)
      end

      def save
        File.open(file, 'w', 0600) { |f| f.write(history.to_yaml) }
      end

      private

      def file
        fail NotImplementedError, 'file method must be implemented'
      end
    end
  end
end
