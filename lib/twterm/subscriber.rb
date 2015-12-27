require 'twterm/event_dispatcher'

module Twterm
  module Subscriber
    def subscribe(event, callback = nil, &block)
      cb = if callback.is_a?(Proc)
             callback
           elsif callback.is_a?(Symbol)
             if self.respond_to?(callback)
               self.method(callback)
             else
               callback.to_proc
             end
           elsif callback.nil?
             callback = block
           end

      EventDispatcher.instance.register_subscription(object_id, event, cb)
    end

    def unsubscribe(event = nil)
      EventDispatcher.instance.unregister_subscription(object_id, event)
    end

    def self.included(base)
      base.instance_eval do
        private :subscribe, :unsubscribe
      end
    end
  end
end
