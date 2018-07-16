require 'twterm/event/message/info'
require 'twterm/tab/abstract_tab'
require 'twterm/tab/loadable'

module Twterm
  module Tab
    module New
      class List < AbstractTab
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

        def matches?(list, query)
          [
            list.description,
            list.full_name,
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
          return Image.string(initially_loaded? ? 'No results found' : 'Loading...') if items.empty?

          drawable_items.map.with_index(0) do |list, i|
            curr = scroller.current_index?(i)
            cursor = Image.cursor(2, curr)

            summary = Image.string("#{list.full_name} (#{list.member_count} members / #{list.subscriber_count} subscribers)").bold(curr)
            desc = Image.string('  ') - Image.string(list.description)

            cursor - Image.whitespace - (summary | desc)
          end
            .intersperse(Image.blank_line)
            .reduce(Image.empty, :|)
        end
      end
    end
  end
end
