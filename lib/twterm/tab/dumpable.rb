module Twterm
  module Tab
    module Dumpable
      def dump
        fail NotImplementedError 'dump method must be implemented'
      end

      def self.included(klass)
        klass.extend(ClassMethods)
      end

      module ClassMethods
        def recover(title, arg)
          tab = new(arg)
          tab.title = title
          tab
        end
      end
    end
  end
end
