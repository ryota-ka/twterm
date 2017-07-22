module Twterm
  module Tab
    module Dumpable
      def dump
        fail NotImplementedError, 'dump method must be implemented'
      end

      def self.included(klass)
        klass.extend(ClassMethods)
      end

      module ClassMethods
        def recover(app, client, title, arg)
          tab = new(app, client, arg)
          tab.title = title
          tab
        end
      end
    end
  end
end
