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
        return image_factory.string('Loading...') unless initially_loaded?

        items
          .drop(scroller.offset)
          .take(drawable_item_count)
          .reduce(image_factory.empty, :|)
      end

      def items
        return [] unless initially_loaded?

        @@status[:resources].flat_map do |category, limits|
          [
            !image_factory.string(category.to_s.gsub('_', ' ')).color(:green),
            image_factory.blank_line,
            *limits.flat_map do |endpoint, data|
              limit, remaining = data[:limit], data[:remaining]
              t = Time.at(data[:reset])
              diff = (t - Time.now).round

              [
                image_factory.string("  #{endpoint}").color(:cyan) - (
                  limit == remaining \
                    ? image_factory.empty
                    : image_factory.string(" (Resets #{diff.positive? ? "in #{diff} seconds" : 'soon...'})")),
                image_factory.string('  ') - image_factory.remaining_resource(remaining, limit, 50) - image_factory.string(" #{remaining}/#{limit}"),
                image_factory.blank_line,
              ]
            end,
            image_factory.blank_line,
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
