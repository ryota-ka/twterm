require 'twterm/tab/statuses/base'

module Twterm
  module Tab
    module Statuses
      class ListTimeline < Base
        include Dumpable

        attr_reader :list

        def initialize(app, client, list_id)
          super(app, client)

          self.title = 'Loading...'.freeze

          find_or_fetch_list(list_id).then do |list|
            @list = list
            self.title = @list.full_name
            app.tab_manager.refresh_window

            fetch.then do
              initially_loaded!
              scroller.move_to_top
            end

            @auto_reloader = Scheduler.new(300) { fetch }
          end
        end

        def fetch
          client.list_timeline(@list).then do |statuses|
            statuses.each { |s| append(s) }
            sort
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
end
