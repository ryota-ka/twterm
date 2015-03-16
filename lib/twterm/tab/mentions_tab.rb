module Twterm
  module Tab
    class MentionsTab
      include StatusesTab

      def initialize(client)
        fail ArgumentError, 'argument must be an instance of Client class' unless client.is_a? Client

        super()

        @client = client
        @client.on_mention do |status|
          prepend(status)
          Notifier.instance.show_message "Mentioned by @#{status.user.screen_name}: #{status.text}"
        end

        @title = 'Mentions'

        fetch { move_to_top }
        auto_reload(300) { fetch }
      end

      def fetch
        @client.mentions do |statuses|
          statuses.reverse.each(&method(:prepend))
          sort
          yield if block_given?
        end
      end

      def close
        fail NotClosableError
      end
    end
  end
end
