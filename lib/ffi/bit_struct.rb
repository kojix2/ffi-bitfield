# frozen_string_literal: true

require 'ffi'
require_relative 'bit_field/version'
require_relative 'bit_field/bit_field_supporter'

module FFI
  class BitStruct < Struct
    extend BitField::BitFiledSupporter
  end
end
