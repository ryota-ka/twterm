class Array
  def intersperse(x)
    ([x] * length).zip(self).flatten(1).drop(1)
  end
end
