# frozen_string_literal: true

require 'ffi'
require_relative 'bit_field/version'
require_relative 'bit_field/class_methods'
require_relative 'bit_field/instance_methods'

module FFI
  # Subclass of FFI::ManagedStruct that supports bit fields.
  # Combines memory management with bit field functionality.
  #
  # Use this class when you need automatic memory management for your structs
  # with bit fields. You must implement the self.release method to handle
  # memory cleanup.
  #
  # @example Define a managed struct with bit fields
  #   class ManagedFlags < FFI::ManagedBitStruct
  #     layout \
  #       :value, :uint8
  #
  #     bit_fields :value,
  #       :read,    1,
  #       :write,   1,
  #       :execute, 1,
  #       :unused,  5
  #
  #     def self.release(ptr)
  #       # Custom memory cleanup code
  #     end
  #   end
  class ManagedBitStruct < ManagedStruct
    # [] is defined in FFI::Struct
    alias get_member_value []
    alias set_member_value []=
    extend BitField::ClassMethods
    # The InstanceMethods module included in the FFI::BitStruct class is
    # * behind the FFI::BitStruct class, but is
    # * in FRONT of the FFI::Struct class.
    # `YourStruct.ancestors`
    # # => [YourStruct, FFI::BitStruct, FFI::BitField::InstanceMethods, FFI::Struct...]
    # So you do not need to use `prepend` instead of `include`.
    include BitField::InstanceMethods
  end
end
