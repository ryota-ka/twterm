require 'twterm/event/notification/info'
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

        def initialize
          super

          Client.current.lists.then do |lists|
            @@lists = lists.sort_by(&:full_name)
            initially_loaded!
          end
        end

        def items
          @@lists || []
        end

        def respond_to_key(key)
          return true if scroller.respond_to_key(key)

          k = KeyMapper.instance

          case key
          when 10
            return true if current_list.nil?
            list_tab = Tab::Statuses::ListTimeline.new(current_list.id)
            TabManager.instance.switch(list_tab)
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
            cursor = Image.cursor(2, scroller.current_index?(i))

            summary = Image.string("#{list.full_name} (#{list.member_count} members / #{list.subscriber_count} subscribers)")
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
