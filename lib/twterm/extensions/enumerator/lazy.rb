class Enumerator
  class Lazy
    def scan(initial, sym = nil)
      acc = initial

      @_scan_has_yielded_initial_value = false

      Enumerator::Lazy.new(self) do |y, x|
        y << initial && @_scan_has_yielded_initial_value = true unless @_scan_has_yielded_initial_value
        acc = sym.nil? ? yield(acc, x) : sym.to_proc.call(acc, x)
        y << acc
      end
    end
  end
end
