require 'twterm/repository/abstract_repository'

module Twterm
  module Repository
    class AbstractEntityRepository < AbstractRepository
      def create(*args)
        invoke_callbacks(:before_create, *args)

        existing_instance = find(extract_key(args))

        instance = existing_instance.nil? ? type.new(*args) : existing_instance.update!(*args)

        store(instance)

        invoke_callbacks(:after_create, instance)

        instance
      end

      def find(key)
        repository[key]
      end

      private

      def empty_repository
        {}
      end

      def extract_key(args)
        args[0].id
      end

      def store(instance)
        repository[instance.id] = instance
      end
    end
  end
end
