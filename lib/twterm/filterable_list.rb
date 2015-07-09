module Twterm
  module FilterableList
    extend Forwardable

    def filter
      @filter_query = FilterQueryWindow.instance.input

      if filter_query.empty?
        reset_filter
      elsif items.count == 0
        query = filter_query
        reset_filter
        Notifier.instance.show_error "No matches found: \"#{query}\""
      else
        Notifier.instance.show_message "#{total_item_count} statuses found: \"#{filter_query}\""
        scroller.move_to_top
      end

      refresh
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
    end
  end
end
