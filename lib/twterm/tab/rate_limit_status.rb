require 'twterm/tab/loadable'

module Twterm
  module Tab
    class RateLimitStatus < Tab::Base
      include Loadable
      include Scrollable

      @@mutex = Mutex.new
      @@status = nil

      def initialize(app, client)
        super(app, client)

        scroller.set_no_cursor_mode!

        @ticker = Scheduler.new(1) { render }

        @scheduler = Scheduler.new(10) { fetch }

        fetch.then { initially_loaded! }
      end

      def close
        @scheduler.kill
        @ticker.kill
        super
      end

      def drawable_item_count
        window.maxy - 2
      end

      def image
        return Image.string('Loading...') unless initially_loaded?

        items
          .drop(scroller.offset)
          .take(drawable_item_count)
          .reduce(Image.empty, :|)
      end

      def items
        return [] unless initially_loaded?

        @@status[:resources].flat_map do |category, limits|
          [
            !Image.string(category.to_s.gsub('_', ' ')).color(:green),
            Image.blank_line,
            *limits.flat_map do |endpoint, data|
              limit, remaining = data[:limit], data[:remaining]
              t = Time.at(data[:reset])
              diff = (t - Time.now).round

              [
                Image.string("  #{endpoint}").color(:cyan) - (
                  limit == remaining \
                    ? Image.empty
                    : Image.string(" (Resets #{diff.positive? ? "in #{diff} seconds" : 'soon...'})")),
                Image.string('  ') - Image.remaining_resource(remaining, limit, 50) - Image.string(" #{remaining}/#{limit}"),
                Image.blank_line,
              ]
            end,
            Image.blank_line,
          ]
        end
      end

      def respond_to_key(key)
        scroller.respond_to_key(key)
      end

      def title
        'Rate Limit Status'.freeze
      end

      private

      def fetch
        client.rate_limit_status.then { |status| @@mutex.synchronize { @@status = status } }
      end
    end
  end
end
