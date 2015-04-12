class Scheduler
  def initialize(interval, &block)
    fail ArgumentError, 'Interval must be a real number' unless interval.is_a?(Numeric) && interval.real?
    fail RangeError, 'Interval must be greater than zero' unless interval > 0

    @interval, @block = interval, block
    @paused = false

    @thread = Thread.new do
      sleep @interval
      run
    end
  end

  def kill
    @thread.kill
  end

  def pause
    @paused = true
  end

  def run
    @block.call unless @paused
  end

  def unpause
    @paused = false
  end
end
