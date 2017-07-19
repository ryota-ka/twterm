require 'twterm/repository/abstract_entity_repository'

module Twterm
  module Repository
    class AbstractExpirableEntityRepository < AbstractEntityRepository
      def initialize
        super
        @touched_at = {}
      end

      def create(args)
        touch(args.id)
        super
      end

      def find(id)
        touch(id)
        super
      end

      def expire(threshold)
        now = Time.now
        repository.delete_if { |id, _| !@touched_at[id] || @touched_at[id] + threshold < now }
      end

      private

      def touch(id)
        @touched_at[id] = Time.now
      end
    end
  end
end
