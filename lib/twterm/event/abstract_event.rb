require 'twterm/utils'

module Twterm
  module Event
    class AbstractEvent
      include Utils

      def initialize(*args)
        fields.zip(args).map(&:flatten).each do |name, type, value|
          check_type type, value

          instance_variable_set('@%s' % name, value)
          self.class.send(:attr_reader, name)
        end
      end

      def fields
        []
      end
    end
  end
end
