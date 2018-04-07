require 'twterm/event/message/info'
require 'twterm/tab/base'
require 'twterm/tab/loadable'

module Twterm
  module Tab
    module New
      class List < Base
        include Loadable
        include Publisher
        include Searchable

        @@lists = nil

        def ==(other)
          other.is_a?(self.class)
        end

        def drawable_item_count
          (window.maxy - 6).div(3)
        end

        def initialize(app, client)
          super(app, client)

          client.lists.then do |lists|
            @@lists = lists.sort_by(&:full_name)
            initially_loaded!
          end
        end

        def items
          @@lists || []
        end

        def matches?(_list, query)
          [
            other.description,
            other.full_name,
          ].any? { |x| x.downcase.include?(query.downcase) }
        end

        def respond_to_key(key)
          return true if scroller.respond_to_key(key)

          case key
          when 10
            return true if current_list.nil?
            list_tab = Tab::Statuses::ListTimeline.new(app, client, current_list.id)
            app.tab_manager.switch(list_tab)
          else
            return false
          end

          true
        end

        def title
          'New tab'.freeze
        end

        def total_item_count
          items.count
        end

        private

        def current_list
          @@lists.nil? ? nil : items[scroller.index]
        end

        def image
          return image_factory.string(initially_loaded? ? 'No results found' : 'Loading...') if items.empty?

          drawable_items.map.with_index(0) do |list, i|
            curr = scroller.current_index?(i)
            cursor = image_factory.cursor(2, curr)

            summary = image_factory.string("#{list.full_name} (#{list.member_count} members / #{list.subscriber_count} subscribers)").bold(curr)
            desc = image_factory.string('  ') - image_factory.string(list.description)

            cursor - image_factory.whitespace - (summary | desc)
          end
            .intersperse(image_factory.blank_line)
            .reduce(image_factory.empty, :|)
        end
      end
    end
  end
end
