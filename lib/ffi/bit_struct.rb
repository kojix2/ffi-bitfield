# frozen_string_literal: true

require 'ffi'
require_relative 'bit_field/version'
require_relative 'bit_field/layout'
require_relative 'bit_field/property'

module FFI
  # Subclass of FFI::Struct that supports bit fields.
  # Allows defining and accessing individual bits within integer fields.
  #
  # @example Define a struct with bit fields
  #   class Flags < FFI::BitStruct
  #     layout \
  #       :value, :uint8
  #
  #     bit_fields :value,
  #       :read,    1,  # 1 bit for read permission
  #       :write,   1,  # 1 bit for write permission
  #       :execute, 1,  # 1 bit for execute permission
  #       :unused,  5   # 5 unused bits
  #   end
  #
  #   flags = Flags.new
  #   flags[:read] = 1
  #   flags[:write] = 1
  #   puts flags[:value]  # => 3
  class BitStruct < Struct
    # [] is defined in FFI::Struct
    alias get_member_value []
    alias set_member_value []=
    extend BitField::Layout
    # The Property module included in the FFI::ManagedBitStruct class is
    # * behind the FFI::ManagedBitStruct class, but is
    # * in FRONT of the FFI::Struct class.
    # `MStruct.ancestors`
    # # => [MStruct, FFI::ManagedBitStruct, FFI::BitField::Property, FFI::ManagedStruct, FFI::Struct...]
    # So you do not need to use `prepend` instead of `include`.
    include BitField::Property
  end
end
