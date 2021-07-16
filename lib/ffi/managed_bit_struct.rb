# frozen_string_literal: true

require 'ffi'
require_relative 'bit_struct/version'
require_relative 'bit_field_supporter'

module FFI
  class ManagedBitStruct < ManagedStruct
    extend BitFiledSupporter
  end
end
