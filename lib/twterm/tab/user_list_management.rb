require 'twterm/event/notification/success'
require 'twterm/image'
require 'twterm/publisher'
require 'twterm/tab/dumpable'
require 'twterm/tab/loadable'
require 'twterm/tab/searchable'

module Twterm
  module Tab
    class UserListManagement < Base
      include Dumpable
      include Loadable
      include Publisher
      include Searchable

      @@lists = []
      @@mutex = Mutex.new

      def initialize(user_id)
        super()

        @user_id = user_id
        @list_ids = []

        Client.current.owned_lists.then do |lists|
          @@mutex.synchronize { @@lists = lists.sort_by(&:full_name) }
          render
        end

        Client.current.memberships(user_id, filter_to_owned_lists: true, count: 1000).then do |lists|
          mutex.synchronize { @list_ids = lists.map(&:id) }
          initially_loaded!
        end
      end

      def drawable_item_count
        window.maxy / 3
      end

      def dump
        user_id
      end

      def image
        return Image.string(initially_loaded? ? 'No lists found' : 'Loading...') if items.empty?

        drawable_items.map.with_index do |list, i|
          cursor = Image.cursor(2, scroller.current_index?(i))

          summary = Image.checkbox(@list_ids.include?(list.id)) - Image.whitespace - Image.string(list.full_name)
          description = Image.string('    ') - Image.string(list.description)

          cursor - Image.whitespace - (summary | description)
        end
          .intersperse(Image.blank_line)
          .reduce(Image.empty, :|)
      end

      def items
        @@lists
      end

      def respond_to_key(key)
        return true if scroller.respond_to_key(key)

        case key
        when 10 then toggle
        end
      end

      def title
        (user.nil? ? 'Loading' : "@#{user.screen_name} lists").freeze
      end

      private

      attr_reader :list_ids, :user_id

      def user
        User.find(user_id)
      end

      def mutex
        @mutex ||= Mutex.new
      end

      def toggle
        list = scroller.current_item

        if list_ids.include?(list.id)
          Client.current.remove_list_member(list.id, user_id).then do
            @list_ids.delete(list.id)
            publish(Event::Notification::Success.new("Removed @#{user.screen_name} from #{list.name}"))
          end
        else
          Client.current.add_list_member(list.id, user_id).then do
            @list_ids.push(list.id)
            publish(Event::Notification::Success.new("Added @#{user.screen_name} to #{list.name}"))
          end
        end
          .then { render }
      end
    end
  end
end
