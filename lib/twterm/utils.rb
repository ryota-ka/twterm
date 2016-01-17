module Twterm
  module Utils
    module_function

    def check_type(expected_type, argument)
      return if argument.is_a?(expected_type)

      raise TypeError, 'TypeError: wrong argument type %s (expected %s)' % [
        argument.class, expected_type
      ]
    end
  end
end
