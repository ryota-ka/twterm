require 'twterm/tab/base'
require 'twterm/tab/direct_message/conversation_list'
require 'twterm/tab/rate_limit_status'
require 'twterm/tab/preferences/index'

module Twterm
  module Tab
    module New
      class Start < Base
        include Scrollable

        def ==(other)
          other.is_a?(self.class)
        end

        def drawable_item_count
          (window.maxy - 1).div(2)
        end

        def items
          %i(
            direct_messages
            list_tab
            search_tab
            user_tab
            key_assignments_cheatsheet
            rate_limit_status
            preferences
          ).freeze
        end

        def initialize(app, client)
          super(app, client)
          render
        end

        def respond_to_key(key)
          return true if scroller.respond_to_key(key)

          case key
          when 10
            perform_selected_action
          else
            return false
          end
          true
        end

        def title
          'New tab'.freeze
        end

        private

        def image
          drawable_items
            .map.with_index(0) { |item, i|
              curr = scroller.current_index?(i)
              cursor = image_factory.cursor(1, curr)

              desc =
                case item
                when :direct_messages
                  'Direct messages'
                when :list_tab
                  'List tab'
                when :search_tab
                  'Search tab'
                when :user_tab
                  'User tab'
                when :key_assignments_cheatsheet
                  'Key assignments cheatsheet'
                when :rate_limit_status
                  'Rate limit status'
                when :preferences
                  'Preferences'
                end

              cursor - image_factory.whitespace - image_factory.string(desc).bold(curr)
            }
            .intersperse(image_factory.blank_line)
            .reduce(image_factory.empty, :|)
        end

        def open_direct_messages
          switch(Tab::DirectMessage::ConversationList.new(app, client))
        end

        def open_list_tab
          switch(Tab::New::List.new(app, client))
        end

        def open_search_tab
          switch(Tab::New::Search.new(app, client))
        end

        def open_rate_limit_status
          switch(Tab::RateLimitStatus.new(app, client))
        end

        def open_user_tab
          tab = Tab::New::User.new(app, client)
          switch(tab)
          tab.invoke_input
        end

        def open_key_assignments_cheatsheet
          switch(Tab::KeyAssignmentsCheatsheet.new(app, client))
        end

        def open_preferences_tab
          switch(Tab::Preferences::Index.new(app, client))
        end

        def perform_selected_action
          case current_item
          when :direct_messages
            open_direct_messages
          when :list_tab
            open_list_tab
          when :search_tab
            open_search_tab
          when :user_tab
            open_user_tab
          when :key_assignments_cheatsheet
            open_key_assignments_cheatsheet
          when :rate_limit_status
            open_rate_limit_status
          when :preferences
            open_preferences_tab
          end
        end

        def switch(tab)
          app.tab_manager.switch(tab)
        end
      end
    end
  end
end
