require 'concurrent'

require 'twterm/publisher'
require 'twterm/repository/abstract_entity_repository'

module Twterm
  module Repository
    class AbstractExpirableEntityRepository < AbstractEntityRepository
      include Publisher

      def initialize
        super
        @touched_at = Concurrent::Hash.new
      end

      def create(args, *)
        touch(args.id)
        super
      end

      def find(id)
        instance = super
        touch(id) if !instance.nil? && should_keep?(instance)

        instance
      end

      def expire(threshold)
        now = Time.now
        ids = repository.select { |id, _| !@touched_at[id] || @touched_at[id] + threshold < now }

        ids.each { |id| publish(garbage_collection_event_class.new(id)) }

        repository.delete_if { |id, _| ids.include?(id) }
      end

      private

      def garbage_collection_event_class
        raise NotImplementedError, '`garbage_collection_event_class` must be implemented'
      end

      def should_keep?(instance)
        raise NotImplementedError, '`should_keep?` method must be implemented'
      end

      def touch(id)
        @touched_at[id] = Time.now
      end
    end
  end
end
