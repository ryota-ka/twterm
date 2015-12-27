require 'singleton'

module Twterm
  class EventDispatcher
    include Singleton

    def initialize
      @subscriptions = []
    end

    def dispatch(event)
      @subscriptions
        .select { |s| s.event == event.class }
        .map(&:callback)
        .each { |cb| cb.call(event) }

      self
    end

    def register_subscription(subscriber_id, event, callback)
      unless event <= Event::Base
        raise TypeError, 'the second argument must be a subclass of Twterm::Event::Base'
      end

      @subscriptions << Subscription.new(subscriber_id, event, callback)

      self
    end

    def unregister_subscription(subscriber_id, event)
      cond = if event.nil? # remove all subscriptions from the subscriber
               -> s { s.subscriber_id == subscriber_id }
             else          # remove only specified event
               -> s { s.subscriber_id == subscriber_id && s.event == event }
             end

      @subscriptions.reject!(&cond)

      self
    end

    class Subscription
      attr_reader :subscriber_id, :event, :callback

      def initialize(subscriber_id, event, block)
        @subscriber_id, @event, @callback = subscriber_id, event, block
      end

      def ==(other)
        self.class == other.class &&
          subscriber_id == other.subscriber_id &&
          event == other.event
      end
    end
  end
end
