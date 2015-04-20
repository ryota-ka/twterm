module Twterm
  module Tab
    class ListTab
      include StatusesTab
      include Dumpable

      attr_reader :list

      def initialize(list_id)
        super()

        List.find_or_fetch(list_id) do |list|
          @list = list
          @title = @list.full_name
          TabManager.instance.refresh_window
          fetch { move_to_top }
          @auto_reloader = Scheduler.new(300) { fetch }
        end
      end

      def fetch
        client = Client.current
        client.list_timeline(@list) do |statuses|
          statuses.reverse.each(&method(:prepend))
          sort
          yield if block_given?
        end
      end

      def close
        @auto_reloader.kill if @auto_reloader
        super
      end

      def ==(other)
        other.is_a?(self.class) && list == other.list
      end

      def dump
        @list.id
      end
    end
  end
end
