require 'twterm/event/notification'
require 'twterm/publisher'

module Twterm
  module FilterableList
    extend Forwardable

    include Publisher

    def filter
      @filter_query = FilterQueryWindow.instance.input

      if filter_query.empty?
        reset_filter
      elsif items.count == 0
        query = filter_query
        reset_filter
        publish(Event::Notification.new(:error, "No matches found: \"#{query}\""))
      else
        Notifier.instance.show_message "#{total_item_count} items found: \"#{filter_query}\""
        scroller.move_to_top
      end

      render
    end

    def filter_query
      @filter_query ||= ''
    end

    def items
      fail NotImplementedError, 'items method must be implemented'
    end

    def reset_filter
      FilterQueryWindow.instance.clear
      @filter_query = ''
      render
    end
  end
end
