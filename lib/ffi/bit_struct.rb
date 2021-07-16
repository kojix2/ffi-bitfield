# frozen_string_literal: true

require 'ffi'
require_relative 'bit_field/version'
require_relative 'bit_field/layout'
require_relative 'bit_field/property'

module FFI
  # Subclass of FFI::Struct that support bit fields.
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
