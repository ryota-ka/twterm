require 'twterm/event/status_garbage_collected'
require 'twterm/repository/abstract_expirable_entity_repository'
require 'twterm/status'

module Twterm
  module Repository
    class StatusRepository < AbstractExpirableEntityRepository
      def all
        repository.values
      end

      def create(tweet, is_retweeted_status = false)
        create(tweet.retweeted_status, true) unless tweet.retweeted_status.is_a?(Twitter::NullObject)
        super
      end

      def delete(id)
        @touched_at.delete(id)
        repository.delete(id)
      end

      def find(id)
        status = super

        touch(status.retweeted_status_id) if !status.nil? && status.retweet?

        status
      end

      def find_replies_for(id)
        repository.values.select { |s| s.in_reply_to_status_id == id }
      end

      def expire(threshold)
        now = Time.now
        ids = repository
          .to_a
          .sort_by { |_, status| status.created_at }
          .reverse
          .drop(keep_minimum)
          .select { |id, _| !@touched_at[id] || @touched_at[id] + threshold < now }

        ids.each { |id| publish(garbage_collection_event_class.new(id)) }

        repository.delete_if { |id, _| ids.include?(id) }
      end

      def ids
        repository.keys
      end

      private

      def garbage_collection_event_class
        Event::StatusGarbageCollected
      end

      def keep_minimum
        1000
      end

      def should_keep?(status)
        Time.now - status.created_at > 86400
      end

      def type
        Status
      end
    end
  end
end
