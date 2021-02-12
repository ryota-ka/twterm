require 'twterm/image/attr'

class Twterm::Image::Dim < Twterm::Image::Attr
  def to_s
    "\e[2m#{image}\e[0m"
  end

  protected

  def attr
    Curses::A_DIM
  end
end
