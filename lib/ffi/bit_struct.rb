# frozen_string_literal: true

require 'ffi'
require_relative 'bit_struct/version'
require_relative 'bit_field_supporter'

module FFI
  class BitStruct < Struct
    extend BitFiledSupporter
  end
end
