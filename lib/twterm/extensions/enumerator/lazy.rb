class Enumerator
  class Lazy
    def scan(initial, sym = nil)
      acc = initial

      Enumerator::Lazy.new(self) do |y, x|
        acc = sym.nil? ? yield(acc, x) : sym.to_proc.call(acc, x)
        y << acc
      end
    end
  end
end
