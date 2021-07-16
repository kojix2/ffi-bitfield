# frozen_string_literal: true

require 'ffi'
require_relative 'bit_field/version'
require_relative 'bit_field/layout'
require_relative 'bit_field/property'

module FFI
  class BitStruct < Struct
    alias get_member_value []
    extend BitField::Layout
    include BitField::Property
  end
end
