module Twterm
  class Promise
    def initialize
      @state = :pending
      @callbacks = []

      Thread.new do
        yield method(:resolve), method(:reject)
      end if block_given?
    end

    def catch(on_rejected = nil, &block)
      if on_rejected.is_a?(Proc) && block_given?
        fail SyntaxError, 'both block arg and actual block given'
      end

      on_rejected ||= block
      self.then(nil, on_rejected)
    end

    def reject(reason)
      return if settled?

      @state = :rejected
      @reason = reason

      callbacks.each do |cb|
        cb.invoke_on_rejected(reason)
      end
      self
    end

    def rejected?
      state.eql? :rejected
    end

    def resolve(value)
      return if settled?

      @state = :fulfilled
      @value = value

      callbacks.each do |cb|
        cb.invoke_on_fulfilled(value)
      end
      self
    end

    def then(on_fulfilled = nil, on_rejected = nil, &block)
      if (on_fulfilled.is_a?(Proc) || on_rejected.is_a?(Proc)) && block_given?
        fail SyntaxError, 'both block arg and actual block given'
      end

      on_fulfilled ||= block
      next_promise = Promise.new
      callback = Callback.new(
        self,
        on_fulfilled.is_a?(Proc) ? on_fulfilled : nil,
        on_rejected.is_a?(Proc) ? on_rejected : nil,
        next_promise
      )
      @callbacks << callback

      callback.invoke_on_fulfilled(@value) if fulfilled?
      callback.invoke_on_rejected(@reason) if rejected?

      next_promise
    end

    def self.resolve(value)
      Promise.new { |resolve, _| resolve.(value) }
    end

    private

    attr_reader :callbacks, :errorbacks, :next_promises, :state

    def fulfilled?
      state.eql? :fulfilled
    end

    def pending?
      state.eql? :pending
    end

    def rejected?
      state.eql? :rejected
    end

    def settled?
      !pending?
    end

    class Callback
      def initialize(promise, on_fulfilled, on_rejected, next_promise)
        @promise = promise
        @on_fulfilled, @on_rejected = on_fulfilled, on_rejected
        @next_promise = next_promise
      end

      def has_on_fulfilled?
        !on_fulfilled.nil?
      end

      def has_on_rejected?
        !on_rejected.nil?
      end

      def invoke_on_fulfilled(value)
        if has_on_fulfilled?
          new_value = on_fulfilled.(value)
          next_promise.resolve(new_value)
        else
          next_promise.resolve(value)
        end
      rescue => reason
        next_promise.reject(reason)
      end

      def invoke_on_rejected(reason)
        unless has_on_rejected?
          if has_on_fulfilled?
            next_promise.reject(reason)
          else
            raise reason unless has_on_fulfilled?
          end
          return
        end

        begin
          new_value = on_rejected.(reason)
          next_promise.resolve(new_value)
        rescue => reason
          next_promise.reject(reason)
        end
      end

      private

      attr_reader :promise, :on_fulfilled, :on_rejected, :next_promise
    end
  end
end
