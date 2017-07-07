module Twterm
  module Repository
    class AbstractRepository
      def initialize
        @repository = empty_repository

        @callbacks = {
          after_create: [],
          before_create: [],
        }
      end

      def after_create(&block)
        @callbacks[:after_create] << block
      end

      def before_create(&block)
        @callbacks[:before_create] << block
      end

      def create(*args)
        invoke_callbacks(:before_create, *args)

        existing_instance = find(extract_key(args))

        instance = existing_instance.nil? ? type.new(*args) : existing_instance

        store(instance) if existing_instance.nil?

        invoke_callbacks(:after_create, instance)

        instance
      end

      def find(_key)
        raise NotImplementedError, '`find` must be implemented'
      end

      def type
        raise NotImplementedError, '`type` must be implemented'
      end

      private

      attr_reader :repository

      def empty_repository
        raise NotImplementedError, '`empty_repository` must be implemented'
      end

      def extract_key(_args)
        raise NotImplementedError, '`extract_key` must be implemented'
      end

      def invoke_callbacks(type, *args)
        @callbacks[type].each { |cb| cb.call(*args) }
      end

      def store(_instance)
        raise NotImplementedError, '`store` must be implemented'
      end
    end
  end
end
