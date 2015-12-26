require 'twterm/utils'

module Twterm
  module Event
    class Base
      def initialize(*args)
        fields.zip(args).map(&:flatten).each do |name, type, value|
          check_type type, value

          instance_variable_set('@%s' % name, value)
          self.class.send(:attr_reader, name)
        end
      end
    end
  end
end
