class Integer
  def format
    to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')
  end
end
