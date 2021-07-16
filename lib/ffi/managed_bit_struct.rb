# frozen_string_literal: true

require 'ffi'
require_relative 'bit_field/version'
require_relative 'bit_field/layout'
require_relative 'bit_field/property'

module FFI
  # Subclass of FFI::ManagedStruct that support bit fields.
  class ManagedBitStruct < ManagedStruct
    # [] is defined in FFI::Struct
    alias get_member_value []
    extend BitField::Layout
    # The Property module included in the FFI::BitStruct class is
    # * behind the FFI::BitStruct class, but is
    # * in FRONT of the FFI::Struct class.
    # `YourStruct.ancestors`
    # # => [YourStruct, FFI::BitStruct, FFI::BitField::Property, FFI::Struct...]
    # So you do not need to use `prepend` instead of `include`.
    include BitField::Property
  end
end
