# frozen_string_literal: true

require_relative 'bit_field/version'
require_relative 'bit_struct'
require_relative 'managed_bit_struct'

# Foreign Function Interface module for Ruby.
# This is the main namespace for the Ruby-FFI library.
module FFI
  # BitField provides bit field functionality for Ruby-FFI.
  # It allows defining, reading, and writing bit fields within FFI structs.
  #
  # @example Basic usage
  #   class MyStruct < FFI::BitStruct
  #     layout \
  #       :flags, :uint8
  #
  #     bit_fields :flags,
  #       :flag1, 1,
  #       :flag2, 1,
  #       :value, 6
  #   end
  #
  #   struct = MyStruct.new
  #   struct[:flag1] = 1
  #   struct[:value] = 42
  module BitField
  end
end
