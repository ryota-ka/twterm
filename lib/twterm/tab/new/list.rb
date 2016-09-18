require 'twterm/event/notification'
require 'twterm/tab/base'

module Twterm
  module Tab
    module New
      class List < Base
        include FilterableList
        include Scrollable

        @@lists = nil

        def ==(other)
          other.is_a?(self.class)
        end

        def drawable_item_count
          (window.maxy - 6).div(3)
        end

        def initialize
          super

          refresh
        end

        def items
          (@@lists || []).select { |l| l.matches?(filter_query) }
        end

        def respond_to_key(key)
          return true if scroller.respond_to_key(key)

          k = KeyMapper.instance

          case key
          when 10
            return true if current_list.nil?
            list_tab = Tab::Statuses::ListTimeline.new(current_list.id)
            TabManager.instance.switch(list_tab)
          when k[:tab, :reset_filter]
            reset_filter
          when k[:tab, :filter]
            filter
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

        def show_lists
          return if @@lists.nil?

          index, offset = scroller.index, scroller.offset

          drawable_items.each.with_index(0) do |list, i|
            window.with_color(:black, :magenta) do
              window.setpos(i * 3 + 5, 4)
              window.addstr(' ')
              window.setpos(i * 3 + 6, 4)
              window.addstr(' ')
            end if scroller.current_item?(i)

            window.setpos(i * 3 + 5, 6)
            window.addstr("#{list.full_name} (#{list.member_count} members / #{list.subscriber_count} subscribers)")
            window.setpos(i * 3 + 6, 8)
            window.addstr(list.description)
          end
        end

        def update
          window.setpos(2, 3)
          window.bold { window.addstr('Open list tab') }

          Thread.new do
            publish(Event::Notification.new(:message, 'Loading lists ...'))
            Client.current.lists.then do |lists|
              @@lists = lists.sort_by(&:full_name)
              show_lists
              window.refresh if TabManager.instance.current_tab == self
            end
          end if @@lists.nil?

          show_lists
        end
      end
    end
  end
end
