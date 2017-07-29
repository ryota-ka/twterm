module Twterm
  class KeyMapper
    class NoSuchCommand < StandardError
      attr_reader :category, :command

      def initialize(category, command)
        @category, @command = category, command
        super(message)
      end

      def full_command
        "#{category}.#{command}"
      end

      def message
        "No such command: #{full_command}"
      end
    end
  end
end
